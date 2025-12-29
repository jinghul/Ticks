//
//  TimerInterval.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import Foundation
import SwiftData

@Model
final class TimerInterval {
    var id: UUID
    var label: String
    var duration: TimeInterval
    var confirmationTypeRaw: String
    var orderIndex: Int
    var session: TimerSession?

    var confirmationType: ConfirmationType {
        get { ConfirmationType(rawValue: confirmationTypeRaw) ?? .automatic }
        set { confirmationTypeRaw = newValue.rawValue }
    }

    init(id: UUID = UUID(), label: String, duration: TimeInterval, confirmationType: ConfirmationType = .automatic, orderIndex: Int = 0) {
        self.id = id
        self.label = label
        self.duration = duration
        self.confirmationTypeRaw = confirmationType.rawValue
        self.orderIndex = orderIndex
    }

    enum ConfirmationType: String, Codable, CaseIterable {
        case automatic = "automatic"
        case manual = "manual"

        var displayName: String {
            switch self {
            case .automatic: return "Automatic"
            case .manual: return "Manual Confirmation"
            }
        }
    }
}
