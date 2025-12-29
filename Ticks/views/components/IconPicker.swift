//
//  IconPicker.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import SwiftUI

struct IconPicker: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    let icons = [
        "timer", "clock", "alarm", "stopwatch",
        "figure.run", "figure.walk", "figure.yoga", "figure.strengthtraining.traditional",
        "dumbbell", "tennis.racket", "basketball", "football",
        "brain.head.profile", "book", "pencil", "paintbrush",
        "cup.and.saucer", "fork.knife", "leaf", "heart",
        "moon.stars", "sun.max", "flame", "snowflake",
        "bolt", "star", "sparkles", "music.note"
    ]

    let columns = [
        GridItem(.adaptive(minimum: 70))
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(icons, id: \.self) { icon in
                        Button(action: {
                            selectedIcon = icon
                            dismiss()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedIcon == icon ? Color.black : Color.gray.opacity(0.1))
                                    .frame(width: 70, height: 70)

                                Image(systemName: icon)
                                    .font(.system(size: 28))
                                    .foregroundColor(selectedIcon == icon ? .white : .black)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    IconPicker(selectedIcon: .constant("timer"))
}
