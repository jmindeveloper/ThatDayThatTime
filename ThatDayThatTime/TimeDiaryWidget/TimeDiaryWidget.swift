//
//  TimeDiaryWidget.swift
//  TimeDiaryWidget
//
//  Created by J_Min on 7/1/24.
//

import WidgetKit
import SwiftUI

struct TimeDiaryWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(uiColor: .viewBackgroundColor)
            
            TimeDiaryMediumWidgetView(diary: entry.diary)
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

@available(iOS 17.0, *)
#Preview(as: .systemMedium) {
    TimeDiaryWidget()
} timeline: {
    DiaryEntry(date: .now, diary: dummyDiary)
}
