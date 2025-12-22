//
//  View+CardStyle.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
    }
}
