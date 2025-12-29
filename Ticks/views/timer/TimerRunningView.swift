//
//  TimerRunningView.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import SwiftUI

struct TimerRunningView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = TimerViewModel()

    let session: TimerSession

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                HStack {
                    Button(action: {
                        viewModel.stop()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        Text(session.name)
                            .font(.system(size: 18, weight: .semibold))

                        Text("Interval \(viewModel.currentIntervalIndex + 1) of \(session.sortedIntervals.count)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top)

                Spacer()

                // Circular progress
                if let currentInterval = viewModel.currentInterval {
                    CircularProgressView(
                        progress: viewModel.progress,
                        timeRemaining: viewModel.timeRemaining,
                        intervalLabel: currentInterval.label
                    )
                }

                // Overall progress
                VStack(spacing: 8) {
                    HStack {
                        Text("Overall Progress")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        Spacer()

                        Text("\(Int(viewModel.overallProgress * 100))%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))

                            // Progress
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black)
                                .frame(width: geometry.size.width * viewModel.overallProgress)
                                .animation(.linear(duration: 0.1), value: viewModel.overallProgress)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 32)

                Spacer()

                // Upcoming intervals
                if viewModel.currentIntervalIndex + 1 < session.sortedIntervals.count {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("UP NEXT")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)

                        VStack(spacing: 8) {
                            ForEach(Array(session.sortedIntervals[(viewModel.currentIntervalIndex + 1)...].prefix(3))) { interval in
                                HStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 8)

                                    Text(interval.label)
                                        .font(.system(size: 15))

                                    Spacer()

                                    Text(interval.duration.formattedTime)
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Controls
                controlButtons
                    .padding(.horizontal)
                    .padding(.bottom, 32)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                viewModel.handleAppBecameActive()
            case .background:
                viewModel.handleAppWentToBackground()
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        .onAppear {
            viewModel.start(session: session)
        }
    }

    @ViewBuilder
    private var controlButtons: some View {
        switch viewModel.state {
        case .running:
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.pause()
                }) {
                    HStack {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 20))
                        Text("Pause")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .cornerRadius(16)
                }

                Button(action: {
                    viewModel.nextInterval()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                }
            }

        case .paused:
            Button(action: {
                viewModel.resume()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                    Text("Resume")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.black)
                .cornerRadius(16)
            }

        case .waitingForConfirmation:
            VStack(spacing: 16) {
                Text("Ready to continue?")
                    .font(.system(size: 18, weight: .semibold))

                Button(action: {
                    viewModel.confirmAndContinue()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.green)
                    .cornerRadius(16)
                }
            }

        case .completed:
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)

                Text("Session Complete!")
                    .font(.system(size: 24, weight: .semibold))

                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
                        .cornerRadius(16)
                }
            }

        case .idle:
            EmptyView()
        }
    }
}

#Preview {
    let session = TimerSession(name: "HIIT Workout", iconName: "figure.run")
    let interval1 = TimerInterval(label: "Warm Up", duration: 300, orderIndex: 0)
    let interval2 = TimerInterval(label: "Sprint", duration: 60, orderIndex: 1)
    let interval3 = TimerInterval(label: "Rest", duration: 30, orderIndex: 2)
    session.intervals = [interval1, interval2, interval3]

    return TimerRunningView(session: session)
}
