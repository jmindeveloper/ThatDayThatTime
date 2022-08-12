//
//  CoreDataManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation
import CoreData
import Combine

final class CoreDataManager {
    
    // MARK: - Properties
    private let containerName = "ThatDayThatTime"
    private let persistentContainer: NSPersistentContainer
    let fetchDiary = PassthroughSubject<[Diary], Never>()
    
    // MARK: - LifeCycle
    init() {
        self.persistentContainer = NSPersistentContainer(name: containerName)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print(String(describing: error))
            }
        }
        // db를 보기위한 경로추적용 log
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
    }
    
    // MARK: - Method
    /// diary 목록 가져오기
    func getDiary(type: DiaryType) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: type.entityName)
        
        guard let diary = try? persistentContainer.viewContext.fetch(fetchRequest) as? [Diary] else {
            return
        }
        
        fetchDiary.send(diary)
    }
    
    /// diary 저장하기
    func saveDiary(type: DiaryType, diary: DiaryEntity) {
        guard let entity = NSEntityDescription.entity(forEntityName: type.entityName, in: persistentContainer.viewContext) else { return }
        
        let newDiary = NSManagedObject(entity: entity, insertInto: persistentContainer.viewContext)
        newDiary.setValue(diary.id, forKey: "id")
        newDiary.setValue(diary.date, forKey: "date")
        newDiary.setValue(diary.content, forKey: "content")
        newDiary.setValue(diary.image, forKey: "image")
        
        if type == .time {
            newDiary.setValue(diary.time, forKey: "time")
        }
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
        }
        getDiary(type: type)
    }
    
    /// diary 삭제하기
    func deleteDiary(diary: Diary, type: DiaryType) {
        guard let object = diary as? NSManagedObject else { return }
        persistentContainer.viewContext.delete(object)
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
        }
        getDiary(type: type)
    }
    
    /// diary 수정하기
    func updateDiary(type: DiaryType, originalDiary: Diary, diary: DiaryEntity) {
        if let timeDiary = originalDiary as? TimeDiary {
            timeDiary.content = diary.content
            timeDiary.image = diary.image
            timeDiary.time = diary.time
            timeDiary.date = diary.date
        } else if let dayDiary = originalDiary as? DayDiary {
            dayDiary.content = diary.content
            dayDiary.image = diary.image
            dayDiary.date = diary.date
        }
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
        }
        getDiary(type: type)
    }
}
