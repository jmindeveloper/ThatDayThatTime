//
//  Provider.swift
//  ThatDayThatTime
//
//  Created by J_Min on 7/1/24.
//

import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DiaryEntry {
        DiaryEntry(date: Date(), diary: dummyDiary)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DiaryEntry>) -> Void) {
        var entrys: [DiaryEntry] = []
        
        let currentDate = Date()
        for minOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: minOffset, to: currentDate)!
            
            let entry = DiaryEntry(date: entryDate, diary: dummyDiary)
            entrys.append(entry)
        }
        
        let timeLine = Timeline(entries: entrys, policy: .atEnd)
        completion(timeLine)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DiaryEntry) -> Void) {
        completion(DiaryEntry(date: Date(), diary: dummyDiary))
    }
}
