//
//  Provider.swift
//  ThatDayThatTime
//
//  Created by J_Min on 7/1/24.
//

import WidgetKit

struct Provider: TimelineProvider {
    let coreDataManager = CoreDataManager()
    
    func placeholder(in context: Context) -> DiaryEntry {
        DiaryEntry(date: Date(), diary: dummyDiary)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DiaryEntry>) -> Void) {
        
        guard let diary = coreDataManager.fetchLatestTimeDiary() else {
            let entryDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            let entry = DiaryEntry(date: entryDate, diary: dummyDiary)
            let timeLine = Timeline(entries: [entry], policy: .atEnd)
            completion(timeLine)
            return
        }
        
        let entryDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let entry = DiaryEntry(date: entryDate, diary: DiaryEntity(
            content: diary.content,
            date: diary.date,
            id: diary.id,
            image: nil,
            time: diary.time
        ))
        let timeLine = Timeline(entries: [entry], policy: .atEnd)
        completion(timeLine)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DiaryEntry) -> Void) {
        completion(DiaryEntry(date: Date(), diary: dummyDiary))
    }
}
