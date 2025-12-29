//
//  HapticManager.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/28/25.
//

import UIKit

class HapticManager {
    static let shared = HapticManager()

    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
    }

    func intervalCompleted() {
        impactHeavy.impactOccurred()
    }

    func intervalStarted() {
        impactMedium.impactOccurred()
    }

    func confirmationNeeded() {
        notification.notificationOccurred(.warning)
    }

    func sessionCompleted() {
        notification.notificationOccurred(.success)
    }
}
