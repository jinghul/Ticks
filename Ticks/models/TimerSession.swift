//
//  TimerSession.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import Foundation
import SwiftData

@Model
final class TimerSession {
    var id: UUID
    var name: String
    var iconName: String
    var createdDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \TimerInterval.session)
    var intervals: [TimerInterval]
    
    var totalDuration: TimeInterval {
        intervals.reduce(0) { $0 + $1.duration }
    }
    
    var sortedIntervals: [TimerInterval] {
        intervals.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    init(id: UUID = UUID(), name: String, iconName: String = "timer", intervals: [TimerInterval] = [], createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.intervals = intervals
        self.createdDate = createdDate
    }
}
