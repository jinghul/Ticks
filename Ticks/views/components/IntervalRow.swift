//
//  IntervalRow.swift
//  Ticks
//
//  Created by Jinghu Lei on 12/21/25.
//

import SwiftUI
import SwiftData

struct IntervalRow: View {
    @Bindable var interval: TimerInterval
    let onDelete: () -> Void
    
    @State private var isEditing = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Drag handle
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    if isEditing {
                        TextField("Label", text: $interval.label)
                            .font(.system(size: 16, weight: .medium))
                    } else {
                        Text(interval.label)
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Text(interval.duration.formattedTime)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Confirmation type badge
                Text(interval.confirmationType == .manual ? "Manual" : "Auto")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(interval.confirmationType == .manual ? .orange : .green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        (interval.confirmationType == .manual ? Color.orange : Color.green)
                            .opacity(0.1)
                    )
                    .cornerRadius(8)
                
                // Edit button
                Button(action: { isEditing.toggle() }) {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .frame(width: 32, height: 32)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.white)
            
            if isEditing {
                VStack(spacing: 16) {
                    // Duration picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        DurationPicker(duration: $interval.duration)
                    }
                    
                    // Confirmation type picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Continuation")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Picker("Continuation", selection: $interval.confirmationTypeRaw) {
                            ForEach(TimerInterval.ConfirmationType.allCases, id: \.rawValue) { type in
                                Text(type.displayName).tag(type.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
            }
        }
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

struct DurationPicker: View {
    @Binding var duration: TimeInterval
    
    private var minutes: Int {
        get { Int(duration) / 60 }
        nonmutating set {
            let currentSeconds = Int(duration) % 60
            duration = TimeInterval(newValue * 60 + currentSeconds)
        }
    }
    
    private var seconds: Int {
        get { Int(duration) % 60 }
        nonmutating set {
            let currentMinutes = Int(duration) / 60
            duration = TimeInterval(currentMinutes * 60 + newValue)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Minutes
            HStack {
                Button(action: {
                    if minutes > 0 {
                        minutes -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                
                Text("\(minutes)")
                    .font(.system(size: 32, weight: .semibold))
                    .frame(width: 60)
                
                Button(action: { if minutes < 99 { minutes += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
            
            Text(":")
                .font(.system(size: 32, weight: .semibold))
            
            // Seconds
            HStack {
                Button(action: { if seconds > 0 { seconds -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                
                Text(String(format: "%02d", seconds))
                    .font(.system(size: 32, weight: .semibold))
                    .frame(width: 60)
                
                Button(action: { if seconds < 59 { seconds += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TimerInterval.self, configurations: config)
    
    let interval = TimerInterval(label: "Work", duration: 300, confirmationType: .automatic, orderIndex: 0)
    
    return IntervalRow(interval: interval, onDelete: {})
        .padding()
        .background(Color(.systemGroupedBackground))
        .modelContainer(container)
}
