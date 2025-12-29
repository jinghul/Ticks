//
//  TimerActivityAttributes.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/28/25.
//

import ActivityKit
import Foundation

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Current interval info
        let currentIntervalLabel: String
        let currentIntervalIndex: Int
        let totalIntervals: Int

        // Time tracking
        let intervalEndDate: Date  // When current interval will complete

        // Progress
        let overallProgress: Double  // 0.0 to 1.0

        // State
        let timerState: String  // "running", "paused", "waiting", "completed"

        // Next interval preview
        let nextIntervalLabel: String?
    }

    // Static attributes (don't change during activity)
    let sessionId: String
    let sessionName: String
}
