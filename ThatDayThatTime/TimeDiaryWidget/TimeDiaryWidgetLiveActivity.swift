//
//  TimeDiaryWidgetLiveActivity.swift
//  TimeDiaryWidget
//
//  Created by J_Min on 7/1/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimeDiaryWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TimeDiaryWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimeDiaryWidgetAttributes.self) { context in
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

extension TimeDiaryWidgetAttributes {
    fileprivate static var preview: TimeDiaryWidgetAttributes {
        TimeDiaryWidgetAttributes(name: "World")
    }
}

extension TimeDiaryWidgetAttributes.ContentState {
    fileprivate static var smiley: TimeDiaryWidgetAttributes.ContentState {
        TimeDiaryWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TimeDiaryWidgetAttributes.ContentState {
         TimeDiaryWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TimeDiaryWidgetAttributes.preview) {
   TimeDiaryWidgetLiveActivity()
} contentStates: {
    TimeDiaryWidgetAttributes.ContentState.smiley
    TimeDiaryWidgetAttributes.ContentState.starEyes
}
