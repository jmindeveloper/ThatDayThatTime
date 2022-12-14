//
//  WiritngTimeDiaryViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/11.
//

import UIKit
import Combine
import PhotosUI

final class WritingTimeDiaryViewModel: NSObject {
    
    // MARK: - Properties
    var time: CurrentValueSubject<String, Never>
    var diary: String
    var image: CurrentValueSubject<UIImage?, Never>
    var date: CurrentValueSubject<String, Never>
    private var originalDiary: TimeDiary?
    private let coreDataManager: CoreDataManager
    
    // MARK: - LifeCycle
    private init(timeDiary: TimeDiary?, date: String?, coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        self.originalDiary = timeDiary
        self.time = CurrentValueSubject<String, Never>(timeDiary?.time ?? String.getTime())
        self.diary = timeDiary?.content ?? ""
        self.image = CurrentValueSubject<UIImage?, Never>(UIImage.getImage(with: timeDiary))
        self.date = CurrentValueSubject<String, Never>(timeDiary?.date ?? date ?? String.getDate())
    }
    
    convenience init(timeDiary: TimeDiary, coreDataManager: CoreDataManager) {
        self.init(timeDiary: timeDiary, date: nil, coreDataManager: coreDataManager)
    }
    
    convenience init(date: String, coreDataManager: CoreDataManager) {
        self.init(timeDiary: nil, date: date, coreDataManager: coreDataManager)
    }
}

// MARK: - Method
extension WritingTimeDiaryViewModel {
    func saveTimeDiary() {
        
        let newDiary = DiaryEntity(
            content: diary,
            date: date.value,
            id: originalDiary?.id ?? UUID().uuidString,
            image: image.value,
            time: time.value
        )
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if let originalDiary = self.originalDiary {
                self.coreDataManager.updateDiary(type: .time, originalDiary: originalDiary, diary: newDiary)
            } else {
                self.coreDataManager.saveDiary(type: .time, diary: newDiary)
            }
        }
    }
    
    func getDiaryStringCount() -> Int {
        return diary.count
    }
}

// MARK: - UII magePickerControllerDelegate
extension WritingTimeDiaryViewModel: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        image.send(selectedImage)
    }
}

extension WritingTimeDiaryViewModel: UINavigationControllerDelegate {
    
}

// MARK: - PHPickerViewControllerDelegate
@available(iOS 14, *)
extension WritingTimeDiaryViewModel: PHPickerViewControllerDelegate {
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
