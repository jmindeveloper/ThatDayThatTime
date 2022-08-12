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
    
    var time: CurrentValueSubject<String, Never>
    var diary: String
    var image: CurrentValueSubject<UIImage?, Never>
    var date: CurrentValueSubject<String, Never>
    private let coreDataManager = CoreDataManager()
    
    init(timeDiary: TimeDiary?) {
        self.time = CurrentValueSubject<String, Never>(timeDiary?.time ?? String.getTime())
        self.diary = timeDiary?.content ?? ""
        self.image = CurrentValueSubject<UIImage?, Never>(UIImage.getImage(with: timeDiary))
        self.date = CurrentValueSubject<String, Never>(timeDiary?.date ?? String.getDate())
    }
    
    func saveTimeDiary(completion: @escaping () -> Void) {
        let newDiary = DiaryEntity(
            content: diary,
            date: date.value,
            id: UUID().uuidString,
            // TODO: - JPEGData? pngData?
            // TODO: - UIImage(data:) 함수는 느린가?
            // TODO: - 그렇다면 리사이징을 해야하나?
            image: image.value?.pngData(),
            time: time.value
        )
        coreDataManager.saveDiary(type: .time, diary: newDiary)
        completion()
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
