//
//  TimerLiveActivity.swift
//  TicksWidgets
//
//  Created by Jinghu Lei on 12/28/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen/banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded region
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.currentIntervalLabel)
                        .font(.headline)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerText(for: context.state.intervalEndDate))
                        .font(.title2)
                        .monospacedDigit()
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        // Progress bar
                        ProgressView(value: context.state.overallProgress)
                            .tint(.white)

                        // Interval counter
                        Text("Interval \(context.state.currentIntervalIndex + 1) of \(context.state.totalIntervals)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                Text(timerText(for: context.state.intervalEndDate))
                    .monospacedDigit()
                    .font(.caption2)
            } minimal: {
                Image(systemName: "timer")
            }
            .keylineTint(.cyan)
        }
    }

    private func timerText(for endDate: Date) -> String {
        let remaining = max(0, endDate.timeIntervalSinceNow)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TimerActivityAttributes>

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.sessionName)
                        .font(.headline)
                    Text(context.state.currentIntervalLabel)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(timerText(for: context.state.intervalEndDate))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }

            VStack(spacing: 4) {
                ProgressView(value: context.state.overallProgress)
                    .tint(.cyan)

                HStack {
                    Text("Interval \(context.state.currentIntervalIndex + 1) of \(context.state.totalIntervals)")
                        .font(.caption2)

                    Spacer()

                    Text("\(Int(context.state.overallProgress * 100))%")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }

            if let nextInterval = context.state.nextIntervalLabel {
                HStack {
                    Text("UP NEXT:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(nextInterval)
                        .font(.caption)
                    Spacer()
                }
            }
        }
        .padding()
    }

    private func timerText(for endDate: Date) -> String {
        let remaining = max(0, endDate.timeIntervalSinceNow)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
