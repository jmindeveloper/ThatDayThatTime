//
//  CoreDataManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import Foundation
import CoreData
import CloudKit
import Combine
import UIKit

final class CoreDataManager {
    
    enum FetchFilterType {
        case date, content
        
        var type: String {
            switch self {
            case .date: return "date"
            case .content: return "content"
            }
        }
    }
    
    // MARK: - Properties
    private let containerName = "ThatDayThatTime"
    private lazy var persistentContainer = NSPersistentCloudKitContainer(name: containerName)
    let fetchTimeDiary = PassthroughSubject<[Diary], Never>()
    let fetchDayDiary = PassthroughSubject<[Diary], Never>()
    let fetchFullSizeImage = PassthroughSubject<Data?, Never>()
    let changePersistentContainer = PassthroughSubject<Void, Never>()
    private var fetchDate = String.getDate()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    init() {
        self.persistentContainer = setPersistentCloudKitContainer()
        bindingUserSetting()
        // db를 보기위한 경로추적용 log
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
    }
    
    private func setPersistentCloudKitContainer() -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: containerName)
        
        guard let descriptions = container.persistentStoreDescriptions.first else {
            return container
        }
        
        descriptions.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.J-Min.ThatDayThatTime")
        descriptions.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        descriptions.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        if !UserSettingManager.shared.getICloudSync() {
            descriptions.cloudKitContainerOptions = nil
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print(String(describing: error))
            }
        }
        
        return container
    }
    
    private func bindingUserSetting() {
        UserSettingManager.shared.changeICloudSync
            .sink { [weak self] in
                guard let self = self else { return }
                self.persistentContainer = self.setPersistentCloudKitContainer()
                self.changePersistentContainer.send()
            }.store(in: &subscriptions)
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
            self.getDiary(type: type, filterType: .date, query: self.fetchDate)
        }
    }
    
    /// diary 목록 가져오기
    func getDiary(type: DiaryType, filterType: FetchFilterType, query: String) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: type.entityName)
            
            let predicate = NSPredicate(format: "\(filterType.type) Contains %@", query)
            fetchRequest.predicate = predicate
            
            guard let diary = try? self.persistentContainer.viewContext.fetch(fetchRequest) as? [Diary] else {
                return
            }
            DispatchQueue.main.async {
                if type == .time {
                    self.fetchTimeDiary.send(diary)
                } else {
                    self.fetchDayDiary.send(diary)
                }
            }
        }
    }
    
    /// diary 저장하기
    func saveDiary(type: DiaryType, diary: DiaryEntity) {
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
        guard let object = diary as? NSManagedObject else { return }
        fetchDate = diary.date ?? fetchDate
        persistentContainer.viewContext.delete(object)
        deleteFullSizeImage(id: diary.id)
        
        saveContext(type: type)
    }
    
    /// diary 수정하기
    func updateDiary(type: DiaryType, originalDiary: Diary, diary: DiaryEntity) {
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
    
    /// Image object 가져오기
    private func getImageObject(id: String) -> Image? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Image")
        let predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.predicate = predicate
        
        guard let image = try? (persistentContainer.viewContext.fetch(fetchRequest) as? [Image])?.first else {
            return nil
        }
        
        return image
    }
    
    /// fullSize image 가져오기
    func getFullSizeImage(id: String) {
        let imageObject = getImageObject(id: id)
        let image = imageObject?.image
        
        fetchFullSizeImage.send(image)
    }
    
    /// fullSizeImage 삭제
    private func deleteFullSizeImage(id: String) {
        guard let imageObject = getImageObject(id: id) else { return }
        
        persistentContainer.viewContext.delete(imageObject)
    }
}
