//
//  TimerViewModel.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import Foundation
import SwiftUI
import ActivityKit

@Observable
class TimerViewModel {
    var currentSession: TimerSession?
    var currentIntervalIndex: Int = 0
    var timeRemaining: TimeInterval = 0
    var state: TimerState = .idle

    private var timer: Timer?

    // Timestamp tracking
    private var lastTickUptime: TimeInterval? // Monotonic clock for tick calculations

    private let notificationManager = NotificationManager.shared
    private var liveActivity: Activity<TimerActivityAttributes>?
    private var updateTimer: Timer?

    var currentInterval: TimerInterval? {
        guard let session = currentSession,
              currentIntervalIndex < session.sortedIntervals.count else {
            return nil
        }
        return session.sortedIntervals[currentIntervalIndex]
    }

    var progress: Double {
        guard let interval = currentInterval, interval.duration > 0 else { return 0 }
        return 1.0 - (timeRemaining / interval.duration)
    }

    var overallProgress: Double {
        guard let session = currentSession else { return 0 }
        let intervals = session.sortedIntervals
        guard !intervals.isEmpty else { return 0 }

        var completedDuration: TimeInterval = 0

        // swiftlint:disable:next identifier_name
        for i in 0..<currentIntervalIndex where i < intervals.count {
            completedDuration += intervals[i].duration
        }

        if let current = currentInterval {
            completedDuration += (current.duration - timeRemaining)
        }

        let total = session.totalDuration
        return total > 0 ? completedDuration / total : 0
    }

    func start(session: TimerSession) {
        self.currentSession = session
        self.currentIntervalIndex = 0
        if let firstInterval = session.sortedIntervals.first {
            self.timeRemaining = firstInterval.duration
        }
        self.state = .running
        startTimer()
        startLiveActivity()
        startLiveActivityUpdates()
    }

    func pause() {
        guard state == .running else { return }
        state = .paused
        stopTimer()
        updateLiveActivity()  // Update to show paused state
    }

    func resume() {
        guard state == .paused else { return }

        state = .running
        startTimer()
        updateLiveActivity()  // Update with new end date
    }

    func stop() {
        state = .idle
        stopTimer()
        endLiveActivity()
        notificationManager.cancelAllNotifications()
        currentSession = nil
        currentIntervalIndex = 0
        timeRemaining = 0
    }

    func nextInterval() {
        guard let session = currentSession else { return }

        HapticManager.shared.intervalCompleted()

        currentIntervalIndex += 1

        if currentIntervalIndex >= session.sortedIntervals.count {
            // Timer completed
            HapticManager.shared.sessionCompleted()
            state = .completed
            stopTimer()
            endLiveActivity()
        } else {
            let nextInterval = session.sortedIntervals[currentIntervalIndex]
            timeRemaining = nextInterval.duration

            if nextInterval.confirmationType == .manual {
                HapticManager.shared.confirmationNeeded()
                state = .waitingForConfirmation
                stopTimer()
            } else {
                HapticManager.shared.intervalStarted()
                state = .running
                startTimer()
            }

            updateLiveActivity()
        }
    }

    func confirmAndContinue() {
        guard state == .waitingForConfirmation else { return }
        HapticManager.shared.intervalStarted()
        state = .running
        startTimer()
        updateLiveActivity()
    }

    private func startTimer() {
        stopTimer()

        // Initialize last tick time to now
        lastTickUptime = ProcessInfo.processInfo.systemUptime

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        lastTickUptime = nil
    }

    private func tick() {
        guard state == .running,
              let lastTick = lastTickUptime else { return }

        let currentUptime = ProcessInfo.processInfo.systemUptime
        let elapsed = currentUptime - lastTick

        // Decrement time remaining
        timeRemaining = max(0, timeRemaining - elapsed)

        // Update for next tick
        lastTickUptime = currentUptime

        if timeRemaining <= 0 {
            nextInterval()
        }
    }

    // MARK: - Background Handling

    func handleAppWentToBackground() {
        guard state == .running, let session = currentSession else { return }

        // Schedule notifications as backup (user will still get alerts if app is killed)
        let remainingIntervals = Array(session.sortedIntervals[currentIntervalIndex...])
        notificationManager.scheduleIntervalNotifications(
            intervals: remainingIntervals,
            startDate: Date().addingTimeInterval(timeRemaining)
        )

        // Timestamp calculation handles the timer updates automatically
    }

    func handleAppBecameActive() {
        // Cancel notifications since we're back in foreground
        notificationManager.cancelAllNotifications()

        // The tick() method's timestamp calculation automatically syncs to the correct time
    }

    // MARK: - Live Activities

    private func startLiveActivity() {
        guard let session = currentSession,
              let currentInterval = currentInterval,
              ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = TimerActivityAttributes(
            sessionId: session.id.uuidString,
            sessionName: session.name
        )

        let initialState = TimerActivityAttributes.ContentState(
            currentIntervalLabel: currentInterval.label,
            currentIntervalIndex: currentIntervalIndex,
            totalIntervals: session.sortedIntervals.count,
            intervalEndDate: Date().addingTimeInterval(timeRemaining),
            overallProgress: overallProgress,
            timerState: "running",
            nextIntervalLabel: nextIntervalPreview()
        )

        do {
            liveActivity = try Activity<TimerActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    private func startLiveActivityUpdates() {
        // Update every second for smooth countdown
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateLiveActivity()
        }
    }

    private func updateLiveActivity() {
        guard let session = currentSession,
              let currentInterval = currentInterval,
              let activity = liveActivity else { return }

        // Calculate end date dynamically from current timeRemaining
        let endDate = Date().addingTimeInterval(timeRemaining)

        let timerStateString: String
        switch state {
        case .running:
            timerStateString = "running"
        case .paused:
            timerStateString = "paused"
        case .waitingForConfirmation:
            timerStateString = "waiting"
        case .completed:
            timerStateString = "completed"
        case .idle:
            timerStateString = "idle"
        }

        let newState = TimerActivityAttributes.ContentState(
            currentIntervalLabel: currentInterval.label,
            currentIntervalIndex: currentIntervalIndex,
            totalIntervals: session.sortedIntervals.count,
            intervalEndDate: endDate,
            overallProgress: overallProgress,
            timerState: timerStateString,
            nextIntervalLabel: nextIntervalPreview()
        )

        Task {
            await activity.update(ActivityContent(state: newState, staleDate: nil))
        }
    }

    private func endLiveActivity() {
        guard let activity = liveActivity else { return }

        updateTimer?.invalidate()
        updateTimer = nil

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        liveActivity = nil
    }

    private func nextIntervalPreview() -> String? {
        guard let session = currentSession,
              currentIntervalIndex + 1 < session.sortedIntervals.count else {
            return nil
        }
        return session.sortedIntervals[currentIntervalIndex + 1].label
    }
}
