//
//  CircularProgressView.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let timeRemaining: TimeInterval
    let intervalLabel: String
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: 20
                )
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.black,
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
            
            // Time display
            VStack(spacing: 8) {
                Text(timeRemaining.formattedTimeWithMillis)
                    .font(.system(size: 56, weight: .medium, design: .rounded))
                    .monospacedDigit()
                
                Text(intervalLabel)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 280, height: 280)
    }
}

#Preview {
    CircularProgressView(
        progress: 0.65,
        timeRemaining: 125.5,
        intervalLabel: "Work Phase"
    )
    .padding()
}
