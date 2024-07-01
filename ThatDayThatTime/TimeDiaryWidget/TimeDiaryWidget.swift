//
//  TimeDiaryWidget.swift
//  TimeDiaryWidget
//
//  Created by J_Min on 7/1/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), str: "placeholder")
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let date = Date()
        let entry = SimpleEntry(date: Date(), str: "ksdlafjl;ksfj")
        
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!
        
        let timeLine = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeLine)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date(), str: "placeholder"))
    }
    
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let str: String
}

struct TimeDiaryWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color.red
            VStack {
                Text("Time:")
                Text(entry.date, style: .time)
                
                Text("Favorite Emoji:")
                Text(entry.str)
            }
        }
    }
}

struct TimeDiaryWidget: Widget {
    let kind: String = "TimeDiaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                TimeDiaryWidgetEntryView(entry: entry)
                    .containerBackground(.background, for: .widget)
            } else {
                TimeDiaryWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("그날 그시간")
        .description("최근 시간의 기록을 확인하고 작성해 보세요")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)
    }
}

#Preview(as: .systemSmall) {
    TimeDiaryWidget()
} timeline: {
    SimpleEntry(date: .now, str: "sdafasd")
    SimpleEntry(date: .now, str: "s2dasdgc")
}
