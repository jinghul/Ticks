//
//  TimerState.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import Foundation

enum TimerState {
    case idle
    case running
    case paused
    case waitingForConfirmation
    case completed
}
