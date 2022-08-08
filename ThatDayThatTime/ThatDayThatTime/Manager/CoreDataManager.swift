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
    
    /// diary 목록 가져오기
    func getDiary(type: DiaryType) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: type.entityName)
        
        guard let diary = try? persistentContainer.viewContext.fetch(fetchRequest) as? [Diary] else {
            return
        }
        
        fetchDiary.send(diary)
    }
    
    /// diary 저장하기
    func saveDiary(type: DiaryType) {
        guard let entity = NSEntityDescription.entity(forEntityName: type.entityName, in: persistentContainer.viewContext) else { return }
        
        let diary = NSManagedObject(entity: entity, insertInto: persistentContainer.viewContext)
        diary.setValue(UUID().uuidString, forKey: "id")
        diary.setValue("2022.08.08 월요일", forKey: "date")
        diary.setValue("일기일기일기", forKey: "content")
        diary.setValue(Data(), forKey: "image")
        
        if type == .time {
            diary.setValue("22:55", forKey: "time")
        }
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
        }
    }
    
    /// diary 삭제하기
    func deleteDiary(diary: Diary) {
        guard let object = diary as? NSManagedObject else { return }
        persistentContainer.viewContext.delete(object)
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
        }
    }
}
