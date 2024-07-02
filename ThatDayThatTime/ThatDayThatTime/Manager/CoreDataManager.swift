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
import WidgetKit

let dummyDiary = DiaryEntity(content: "dummy", date: "", id: "dummy_diary", image: nil, time: "")

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
        migrateStoreIfNeeded()
        self.persistentContainer = setPersistentCloudKitContainer()
        bindingUserSetting()
        // db를 보기위한 경로추적용 log
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
    }
    
    private func setPersistentCloudKitContainer() -> NSPersistentCloudKitContainer {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.JMin.ThatDayThatTimeAppGroup") else {
            fatalError()
        }
        let storeURL = url.appendingPathComponent("ThatDayThatTimeAppGroup.sqlite")
        let descriptions = NSPersistentStoreDescription(url: storeURL)
        descriptions.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.J-Min.ThatDayThatTime")
        descriptions.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        descriptions.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        if !UserSettingManager.shared.getICloudSyncSetting() {
            descriptions.cloudKitContainerOptions = nil
        }

        let container = NSPersistentCloudKitContainer(name: containerName)
        container.persistentStoreDescriptions = [descriptions]
        container.loadPersistentStores { description, error in
            print(description)
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
        do {
            try self.persistentContainer.viewContext.save()
        } catch {
            self.persistentContainer.viewContext.rollback()
        }
        self.getDiary(type: type, filterType: .date, query: self.fetchDate)
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
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
    
    func fetchLatestTimeDiary() -> TimeDiary? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: DiaryType.time.entityName)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false),
            NSSortDescriptor(key: "time", ascending: false)
        ]
        fetchRequest.fetchLimit = 1
        
        guard let diarys = try? self.persistentContainer.viewContext.fetch(fetchRequest) as? [TimeDiary],
              let diary = diarys.first else {
            return nil
        }
        
        return diary
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
        ToastMessageManager.requestToast(message: "기록이 저장됐습니다")
    }
    
    /// diary 삭제하기
    func deleteDiary(diary: Diary, type: DiaryType) {
        guard let object = diary as? NSManagedObject else { return }
        fetchDate = diary.date ?? fetchDate
        persistentContainer.viewContext.delete(object)
        deleteFullSizeImage(id: diary.id)
        
        saveContext(type: type)
        ToastMessageManager.requestToast(message: "기록이 삭제됐습니다")
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
        ToastMessageManager.requestToast(message: "기록이 수정됐습니다")
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
    
    func migrateStoreIfNeeded() {
        let fileManager = FileManager.default
        
        /// CoreData URL
        var existingStoreURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ThatDayThatTime.sqlite")
        
        /// appGroup URL
        guard let appGroupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.JMin.ThatDayThatTimeAppGroup") else {
            fatalError("App Group URL could not be created.")
        }
        
        let appGroupStoreURL = appGroupURL.appendingPathComponent("ThatDayThatTimeAppGroup.sqlite")
        print("appGroupStoreURL - ", appGroupStoreURL.path)
        
        // If the existing store does not exist, just setup the new App Group store
        if !fileManager.fileExists(atPath: existingStoreURL.path) {
            existingStoreURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("ThatDayThatTime.sqlite")
            
            print(existingStoreURL.path)
            
            if !fileManager.fileExists(atPath: existingStoreURL.path) {
                return
            }
        }
        
        // If the App Group store already exists, no need to migrate
        if fileManager.fileExists(atPath: appGroupStoreURL.path) {
            try? fileManager.removeItem(at: appGroupStoreURL)
        }
        
        // Perform migration
        do {
            let coordinator = persistentContainer.persistentStoreCoordinator
//            try fileManager.moveItem(at: existingStoreURL, to: appGroupStoreURL)
//            try fileManager.copyItem(at: existingStoreURL, to: appGroupStoreURL)
            
            try coordinator.replacePersistentStore(at: appGroupStoreURL, withPersistentStoreFrom: existingStoreURL, type: .sqlite)
            try coordinator.destroyPersistentStore(at: appGroupStoreURL, type: .sqlite, options: nil)
        } catch {
            fatalError("Failed to migrate store: \(error.localizedDescription)")
        }
    }
}
