//
//  SessionEditorView.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import SwiftUI
import SwiftData

struct SessionEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var session: TimerSession
    let isNew: Bool
    
    @State private var showingIconPicker = false
    
    init(session: TimerSession, isNew: Bool = false) {
        self.session = session
        self.isNew = isNew
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Session Info Section
                    VStack(spacing: 16) {
                        // Icon selector
                        Button(action: { showingIconPicker = true }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black)
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: session.iconName)
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SESSION NAME")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("e.g., HIIT Workout", text: $session.name)
                                .font(.system(size: 20, weight: .medium))
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Intervals Section
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
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isNew ? "New Session" : "Edit Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if isNew {
                            modelContext.delete(session)
                        }
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveSession()
                        dismiss()
                    }
                    .disabled(session.name.isEmpty || session.intervals.isEmpty)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPicker(selectedIcon: $session.iconName)
            }
        }
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
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TimerSession.self, configurations: config)
    
    let session = TimerSession(name: "HIIT Workout", iconName: "figure.run")
    let interval1 = TimerInterval(label: "Warm Up", duration: 300, orderIndex: 0)
    let interval2 = TimerInterval(label: "Sprint", duration: 60, orderIndex: 1)
    session.intervals = [interval1, interval2]
    
    return SessionEditorView(session: session, isNew: false)
        .modelContainer(container)
}
