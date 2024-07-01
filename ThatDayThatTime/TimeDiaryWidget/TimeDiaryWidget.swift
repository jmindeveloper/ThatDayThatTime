//
//  TimeDiaryWidget.swift
//  TimeDiaryWidget
//
//  Created by J_Min on 7/1/24.
//

import WidgetKit
import SwiftUI

let dummyDiary = DiaryEntity(content: "dummy", date: "", id: "dummy_diary", image: nil, time: "")

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), diary: dummyDiary)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entrys: [SimpleEntry] = []
        
        let currentDate = Date()
        for minOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: minOffset, to: currentDate)!
            
            let entry = SimpleEntry(date: entryDate, diary: dummyDiary)
            entrys.append(entry)
        }
        
        let timeLine = Timeline(entries: entrys, policy: .atEnd)
        completion(timeLine)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date(), diary: dummyDiary))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let diary: DiaryEntity
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
                Text(entry.diary.content ?? "")
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
    SimpleEntry(date: .now, diary: dummyDiary)
}
