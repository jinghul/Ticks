//
//  NotificationManager.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/28/25.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }

    func scheduleIntervalNotifications(intervals: [TimerInterval], startDate: Date) {
        cancelAllNotifications()

        var currentTime = startDate

        for (index, interval) in intervals.enumerated() {
            currentTime = currentTime.addingTimeInterval(interval.duration)

            let content = UNMutableNotificationContent()
            content.title = "Interval Complete"
            content.body = interval.label
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: currentTime.timeIntervalSinceNow,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "interval-\(index)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                }
            }
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
