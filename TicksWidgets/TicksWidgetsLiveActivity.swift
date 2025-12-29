//
//  TicksWidgetsLiveActivity.swift
//  TicksWidgets
//
//  Created by Jinghu Lei on 12/28/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TicksWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TicksWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TicksWidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TicksWidgetsAttributes {
    fileprivate static var preview: TicksWidgetsAttributes {
        TicksWidgetsAttributes(name: "World")
    }
}

extension TicksWidgetsAttributes.ContentState {
    fileprivate static var smiley: TicksWidgetsAttributes.ContentState {
        TicksWidgetsAttributes.ContentState(emoji: "😀")
     }

     fileprivate static var starEyes: TicksWidgetsAttributes.ContentState {
         TicksWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TicksWidgetsAttributes.preview) {
   TicksWidgetsLiveActivity()
} contentStates: {
    TicksWidgetsAttributes.ContentState.smiley
    TicksWidgetsAttributes.ContentState.starEyes
}
