//
//  SessionCard.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import SwiftUI
import SwiftData

struct SessionCard: View {
    let session: TimerSession
    let onStart: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black)
                        .frame(width: 64, height: 64)

                    Image(systemName: session.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.name)
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(.black)

                    Text("\(session.intervals.count) interval\(session.intervals.count == 1 ? "" : "s") • \(session.totalDuration.shortFormat)")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }

                Spacer()

                // Action buttons
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .frame(width: 32, height: 32)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }

            // Start button
            Button(action: onStart) {
                Text("Start")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.black)
                    .cornerRadius(16)
            }
        }
        .padding(20)
        .cardStyle()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    // swiftlint:disable force_try
    let container = try! ModelContainer(for: TimerSession.self, configurations: config)

    let session = TimerSession(name: "HIIT Workout", iconName: "figure.run")
    let interval1 = TimerInterval(label: "Warm Up", duration: 300, orderIndex: 0)
    let interval2 = TimerInterval(label: "Sprint", duration: 60, orderIndex: 1)
    session.intervals = [interval1, interval2]

    return SessionCard(
        session: session,
        onStart: { print("Start") },
        onEdit: { print("Edit") },
        onDelete: { print("Delete") }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
