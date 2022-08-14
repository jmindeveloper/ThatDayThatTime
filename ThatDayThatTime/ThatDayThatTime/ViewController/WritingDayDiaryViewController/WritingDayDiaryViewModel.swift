//
//  WritingDayDiaryViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/14.
//

import UIKit
import Combine
import PhotosUI

final class WritingDayDiaryViewModel: NSObject {
    
    // MARK: - Properties
    var diary: String
    var image: CurrentValueSubject<UIImage?, Never>
    var date: CurrentValueSubject<String, Never>
    private var originalDiary: DayDiary?
    private let coreDataManager: CoreDataManager
    
    // MARK: - LifeCycle
    init(dayDiary: DayDiary?, date: String?, coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        self.originalDiary = dayDiary
        self.diary = dayDiary?.content ?? ""
        self.image = CurrentValueSubject<UIImage?, Never>(UIImage.getImage(with: dayDiary))
        self.date = CurrentValueSubject<String, Never>(dayDiary?.date ?? date ?? String.getDate())
    }
    
    convenience init(dayDiary: DayDiary, coreDataManager: CoreDataManager) {
        self.init(dayDiary: dayDiary, date: nil, coreDataManager: coreDataManager)
    }
    
    convenience init(date: String, coreDataManager: CoreDataManager) {
        self.init(dayDiary: nil, date: date, coreDataManager: coreDataManager)
    }
}

// MARK: - Method
extension WritingDayDiaryViewModel {
    func saveTimeDiary() {
        
        let newDiary = DiaryEntity(
            content: diary,
            date: date.value,
            id: originalDiary?.id ?? UUID().uuidString,
            image: image.value
        )
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if let originalDiary = self.originalDiary {
                self.coreDataManager.updateDiary(type: .day, originalDiary: originalDiary, diary: newDiary)
            } else {
                self.coreDataManager.saveDiary(type: .day, diary: newDiary)
            }
        }
    }
    
    func getDiaryStringCount() -> Int {
        return diary.count
    }
}

// MARK: - UII magePickerControllerDelegate
extension WritingDayDiaryViewModel: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        image.send(selectedImage)
    }
}

extension WritingDayDiaryViewModel: UINavigationControllerDelegate {
    
}

// MARK: - PHPickerViewControllerDelegate
@available(iOS 14, *)
extension WritingDayDiaryViewModel: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider,
            itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] selectedImage, error in
                guard let selectedImage = selectedImage as? UIImage else { return }
                DispatchQueue.main.async {
                    self?.image.send(selectedImage)
                }
            }
        }
    }
}
