//
//  SessionEditorView.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import SwiftUI
import SwiftData

// swiftlint:disable:next type_body_length
struct SessionEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var session: TimerSession
    let isNew: Bool
    let onSave: ((TimerSession) -> Void)?

    @State private var showingIconPicker = false
    @State private var isIntervalMode: Bool
    @State private var simpleMinutes: Int = 0
    @State private var simpleSeconds: Int = 0

    init(session: TimerSession, isNew: Bool = false, onSave: ((TimerSession) -> Void)? = nil) {
        self.session = session
        self.isNew = isNew
        self.onSave = onSave
        // Start in interval mode if session already has multiple intervals
        _isIntervalMode = State(initialValue: session.intervals.count > 1)

        // Initialize simple mode values from first interval if exists
        if let firstInterval = session.intervals.first {
            let totalSeconds = Int(firstInterval.duration)
            _simpleMinutes = State(initialValue: totalSeconds / 60)
            _simpleSeconds = State(initialValue: totalSeconds % 60)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Session Info Section
                    VStack(spacing: 16) {
                        // Icon selector
                        Button(
                            action: { showingIconPicker = true },
                            label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.black)
                                        .frame(width: 80, height: 80)

                                    Image(systemName: session.iconName)
                                        .font(.system(size: 36))
                                        .foregroundColor(.white)
                                }
                            }
                        )

                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SESSION NAME")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)

                            TextField("Timer", text: $session.name)
                                .font(.system(size: 20, weight: .medium))
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                    }
                    .padding(.horizontal)

                    // Timer Configuration Section
                    if isIntervalMode {
                        intervalModeView
                    } else {
                        simpleModeView
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isNew ? "New Session" : "Edit Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // Update interval with simple mode values before saving
                        if !isIntervalMode {
                            updateSimpleInterval()
                        }

                        if let onSave = onSave {
                            // New session - let parent handle insertion
                            onSave(session)
                        } else {
                            // Existing session - save changes
                            saveSession()
                        }
                        dismiss()
                    }
                    .disabled(isDoneButtonDisabled)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPicker(selectedIcon: $session.iconName)
            }
        }
    }

    // MARK: - Simple Mode View
    private var simpleModeView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("DURATION")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)

                Spacer()

                Text(TimeInterval(simpleDuration).formattedTime)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            // Duration picker
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    // Minutes
                    VStack(spacing: 8) {
                        Text("MINUTES")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)

                        Picker("Minutes", selection: $simpleMinutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 120)
                    }

                    // Seconds
                    VStack(spacing: 8) {
                        Text("SECONDS")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)

                        Picker("Seconds", selection: $simpleSeconds) {
                            ForEach(0..<60) { second in
                                Text("\(second)").tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 120)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            .padding(.horizontal)

            // Switch to interval mode button
            Button(action: switchToIntervalMode) {
                HStack {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 20))

                    Text("Intervals")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Interval Mode View
    private var intervalModeView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("INTERVALS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)

                Spacer()

                Text("Total: \(session.totalDuration.formattedTime)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            if session.intervals.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "timer")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("No intervals yet")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)

                    Text("Add your first interval to get started")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    ForEach(session.sortedIntervals) { interval in
                        IntervalRow(interval: interval) {
                            deleteInterval(interval)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Add interval button
            Button(action: addInterval) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))

                    Text("Add Interval")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Computed Properties
    private var isDoneButtonDisabled: Bool {
        session.name.isEmpty ||
        (isIntervalMode && session.intervals.isEmpty) ||
        (!isIntervalMode && simpleDuration <= 0)
    }

    private var simpleDuration: Int {
        simpleMinutes * 60 + simpleSeconds
    }

    private func addInterval() {
        let newInterval = TimerInterval(
            label: "Interval \(session.intervals.count + 1)",
            duration: 60,
            orderIndex: session.intervals.count
        )
        session.intervals.append(newInterval)
    }

    private func deleteInterval(_ interval: TimerInterval) {
        if let index = session.intervals.firstIndex(where: { $0.id == interval.id }) {
            session.intervals.remove(at: index)
            // Update order indices
            for (idx, interval) in session.intervals.enumerated() {
                interval.orderIndex = idx
            }
        }
    }

    private func saveSession() {
        // Session is already in the model context, changes are automatically tracked
        try? modelContext.save()
    }

    private func ensureSimpleInterval() {
        if session.intervals.isEmpty {
            let duration = TimeInterval(simpleMinutes * 60 + simpleSeconds)
            let newInterval = TimerInterval(
                label: "Timer",
                duration: duration > 0 ? duration : 60,
                orderIndex: 0
            )
            session.intervals.append(newInterval)
        }
    }

    private func updateSimpleInterval() {
        ensureSimpleInterval()
        if let firstInterval = session.intervals.first {
            firstInterval.duration = TimeInterval(simpleMinutes * 60 + simpleSeconds)
        }
    }

    private func switchToIntervalMode() {
        updateSimpleInterval()
        isIntervalMode = true
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    // swiftlint:disable:next force_try
    let container = try! ModelContainer(for: TimerSession.self, configurations: config)

    let session = TimerSession(name: "HIIT Workout", iconName: "figure.run")
    let interval1 = TimerInterval(label: "Warm Up", duration: 300, orderIndex: 0)
    let interval2 = TimerInterval(label: "Sprint", duration: 60, orderIndex: 1)
    session.intervals = [interval1, interval2]

    return SessionEditorView(session: session, isNew: false)
        .modelContainer(container)
}
