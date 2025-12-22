//
//  TimeInterval+Format.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import Foundation

extension TimeInterval {
    var formattedTime: String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var formattedTimeWithMillis: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        let millis = Int((self.truncatingRemainder(dividingBy: 1)) * 10)
        
        return String(format: "%d:%02d.%d", minutes, seconds, millis)
    }
    
    var shortFormat: String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}
