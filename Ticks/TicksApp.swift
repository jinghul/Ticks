//
//  TicksApp.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import SwiftUI
import SwiftData

@main
struct TicksApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: TimerSession.self, TimerInterval.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SessionListView()
        }
        .modelContainer(modelContainer)
    }
}
