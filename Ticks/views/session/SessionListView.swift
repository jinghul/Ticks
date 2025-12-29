//
//  SessionListView.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimerSession.createdDate, order: .reverse) private var sessions: [TimerSession]

    @State private var showingEditor = false
    @State private var sessionToEdit: TimerSession?
    @State private var showingTimer = false
    @State private var sessionToRun: TimerSession?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if sessions.isEmpty {
                            emptyStateView
                        } else {
                            Text("YOUR TIMERS")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.top)

                            ForEach(sessions) { session in
                                SessionCard(
                                    session: session,
                                    onStart: {
                                        sessionToRun = session
                                        showingTimer = true
                                    },
                                    onEdit: {
                                        sessionToEdit = session
                                        showingEditor = true
                                    },
                                    onDelete: {
                                        deleteSession(session)
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Sessions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: createNewSession) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                if let session = sessionToEdit {
                    SessionEditorView(session: session, isNew: false)
                }
            }
            .fullScreenCover(isPresented: $showingTimer) {
                if let session = sessionToRun {
                    TimerRunningView(session: session)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "timer")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.3))

            Text("No Timer Sessions")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)

            Text("Create your first timer session\nto get started")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button(action: createNewSession) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))

                    Text("Create Session")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color.black)
                .cornerRadius(16)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func createNewSession() {
        let newSession = TimerSession(name: "", iconName: "timer")
        modelContext.insert(newSession)
        sessionToEdit = newSession
        showingEditor = true
    }

    private func deleteSession(_ session: TimerSession) {
        modelContext.delete(session)
        try? modelContext.save()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    // swiftlint:disable force_try
    let container = try! ModelContainer(for: TimerSession.self, configurations: config)

    // Add sample data
    let session1 = TimerSession(name: "HIIT Workout", iconName: "figure.run")
    let interval1 = TimerInterval(label: "Warm Up", duration: 300, orderIndex: 0)
    let interval2 = TimerInterval(label: "Sprint", duration: 60, orderIndex: 1)
    session1.intervals = [interval1, interval2]

    container.mainContext.insert(session1)

    return SessionListView()
        .modelContainer(container)
}
