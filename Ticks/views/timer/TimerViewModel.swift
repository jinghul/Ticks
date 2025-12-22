//
//  TimerViewModel.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import Foundation
import SwiftUI

@Observable
class TimerViewModel {
    var currentSession: TimerSession?
    var currentIntervalIndex: Int = 0
    var timeRemaining: TimeInterval = 0
    var state: TimerState = .idle
    
    private var timer: Timer?
    private var startTime: Date?
    
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
        for i in 0..<currentIntervalIndex {
            if i < intervals.count {
                completedDuration += intervals[i].duration
            }
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
    }
    
    func pause() {
        guard state == .running else { return }
        state = .paused
        stopTimer()
    }
    
    func resume() {
        guard state == .paused else { return }
        state = .running
        startTimer()
    }
    
    func stop() {
        state = .idle
        stopTimer()
        currentSession = nil
        currentIntervalIndex = 0
        timeRemaining = 0
    }
    
    func nextInterval() {
        guard let session = currentSession else { return }
        currentIntervalIndex += 1
        
        if currentIntervalIndex >= session.sortedIntervals.count {
            // Timer completed
            state = .completed
            stopTimer()
        } else {
            let nextInterval = session.sortedIntervals[currentIntervalIndex]
            timeRemaining = nextInterval.duration
            
            if nextInterval.confirmationType == .manual {
                state = .waitingForConfirmation
                stopTimer()
            } else {
                state = .running
            }
        }
    }
    
    func confirmAndContinue() {
        guard state == .waitingForConfirmation else { return }
        state = .running
        startTimer()
    }
    
    private func startTimer() {
        stopTimer()
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        startTime = nil
    }
    
    private func tick() {
        guard state == .running else { return }
        
        timeRemaining -= 0.1
        
        if timeRemaining <= 0 {
            timeRemaining = 0
            nextInterval()
        }
    }
}
