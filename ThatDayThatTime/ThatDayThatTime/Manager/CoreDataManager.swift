//
//  CoreDataManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation
import CoreData
import Combine
import UIKit

final class CoreDataManager {
    
    // MARK: - Properties
    private let containerName = "ThatDayThatTime"
    private let persistentContainer: NSPersistentContainer
    let fetchDiary = PassthroughSubject<[Diary], Never>()
    let fetchFullSizeImage = PassthroughSubject<Data?, Never>()
    private var fetchDate = String.getDate()
    
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
    private func saveContext(type: DiaryType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.persistentContainer.viewContext.save()
            } catch {
                self.persistentContainer.viewContext.rollback()
            }
            self.getDiary(type: type, date: self.fetchDate)
        }
    }
    
    /// diary 목록 가져오기
    func getDiary(type: DiaryType, date: String) {
        DispatchQueue.global().async { [weak self] in
            print("get: ", Thread.isMainThread)
            guard let self = self else { return }
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: type.entityName)
            let predicate = NSPredicate(format: "date = %@", date)
            fetchRequest.predicate = predicate
            
            guard let diary = try? self.persistentContainer.viewContext.fetch(fetchRequest) as? [Diary] else {
                return
            }
            DispatchQueue.main.async {
                print(diary.count)
                self.fetchDiary.send(diary)
            }
        }
    }
    
    /// fullSize image 가져오기
    func getImageObject(id: String) -> Image? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Image")
        let predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.predicate = predicate
        
        guard let image = try? (persistentContainer.viewContext.fetch(fetchRequest) as? [Image])?.first else {
            return nil
        }
        
        return image
    }
    
    func getFullSizeImage(id: String) {
        let imageObject = getImageObject(id: id)
        let image = imageObject?.image
        
        fetchFullSizeImage.send(image)
    }
    
    /// diary 저장하기
    func saveDiary(type: DiaryType, diary: DiaryEntity) {
        print("save: ", Thread.isMainThread)
        fetchDate = diary.date ?? fetchDate
        guard let entity = NSEntityDescription.entity(forEntityName: type.entityName, in: persistentContainer.viewContext) else { return }
        
        let newDiary = NSManagedObject(entity: entity, insertInto: persistentContainer.viewContext)
        let resizeImage = diary.image?.resize(scale: 0.4)
        
        newDiary.setValue(diary.id, forKey: "id")
        newDiary.setValue(diary.date, forKey: "date")
        newDiary.setValue(diary.content, forKey: "content")
        newDiary.setValue(resizeImage?.jpegData(compressionQuality: 1), forKey: "image")
        if type == .time {
            newDiary.setValue(diary.time, forKey: "time")
        }
        
        saveFullSizeImage(id: diary.id, image: diary.image)
        saveContext(type: type)
    }
    
    /// diary 삭제하기
    func deleteDiary(diary: Diary, type: DiaryType) {
        print("delete: ", Thread.isMainThread)
        guard let object = diary as? NSManagedObject else { return }
        fetchDate = diary.date ?? fetchDate
        persistentContainer.viewContext.delete(object)
        
        saveContext(type: type)
    }
    
    /// diary 수정하기
    func updateDiary(type: DiaryType, originalDiary: Diary, diary: DiaryEntity) {
        print("update: ", Thread.isMainThread)
        fetchDate = diary.date ?? fetchDate
        let resizeImage = diary.image?.resize(scale: 0.4)
        
        if let timeDiary = originalDiary as? TimeDiary {
            timeDiary.content = diary.content
            timeDiary.image = resizeImage?.jpegData(compressionQuality: 1)
            timeDiary.time = diary.time
            timeDiary.date = diary.date
        } else if let dayDiary = originalDiary as? DayDiary {
            dayDiary.content = diary.content
            dayDiary.image = resizeImage?.jpegData(compressionQuality: 1)
            dayDiary.date = diary.date
        }
        updateFullSizeImage(id: diary.id, image: diary.image)
        
        saveContext(type: type)
    }
}

extension CoreDataManager {
    /// fullSize 이미지 저장
    private func saveFullSizeImage(id: String?, image: UIImage?) {
        guard let imageEntity = NSEntityDescription.entity(forEntityName: "Image", in: persistentContainer.viewContext) else { return }
        let imageObject = NSManagedObject(entity: imageEntity, insertInto: persistentContainer.viewContext)
        
        imageObject.setValue(id, forKey: "id")
        imageObject.setValue(image?.jpegData(compressionQuality: 1), forKey: "image")
    }
    
    ///  fullSize 이미지 업데이트
    private func updateFullSizeImage(id: String, image: UIImage?) {
        let imageObject = getImageObject(id: id)
        imageObject?.image = image?.jpegData(compressionQuality: 1)
    }
}
