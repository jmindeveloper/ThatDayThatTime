//
//  WritingTimeDiaryViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/10.
//

import UIKit
import Combine
import CombineCocoa
import PhotosUI

final class WritingTimeDiaryViewController: UIViewController {
    
    // MARK: - ViewProperties
    private let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        let navigationItem = UINavigationItem()
        navigationBar.setItems([navigationItem], animated: true)
        
        return navigationBar
    }()
    
    private let dateLineView: DateLineView = {
        let dateLineView = DateLineView()
        
        return dateLineView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = String.getTime()
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let diaryTextView: UITextView = {
        let textView = UITextView()
        textView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        textView.font = .systemFont(ofSize: 17)
        textView.backgroundColor = .viewBackgroundColor
        textView.configure()
        
        return textView
    }()
    
    private let diaryStringCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        
        return label
    }()
    
    private let photoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.tintColor = .lightGray
        
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .lightGray
        
        return button
    }()
    
    // MARK: - Properteis
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel = WritingTimeDiaryViewModel(timeDiary: nil)
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        configureNavigation()
        configureSubViews()
        setConstraintsNavigationBar()
        setConstraintsOfDateLineView()
        setConstraintsOfTimeLabel()
        setConstraintsOfBottomButtons()
        setConstraintsOfImageView()
        setConstraintsOfDiaryTextView()
        setConstraintsOfDiaryStringCountLabel()
        keyboardObserve()
        
        diaryTextView.text = viewModel.diary
        bindingViewModel()
        bindingViewProperties()
        
        configureImageViewGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        diaryTextView.becomeFirstResponder()
    }
    
}

// MARK: - Method
extension WritingTimeDiaryViewController {
    private func configureNavigation() {
        let addTimeDiaryButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: nil
         )
        addTimeDiaryButton.tapPublisher
            .sink { [weak self] in
                self?.presentDismissAlert()
            }.store(in: &subscriptions)
        
        navigationBar.topItem?.rightBarButtonItem = addTimeDiaryButton
    }
    
    private func keyboardObserve() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowChangeConstraint(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    private func openCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    private func openAlbum() {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = viewModel
            present(picker, animated: true)
        } else {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = viewModel
            present(picker, animated: true)
        }
    }
}

// MARK: - TargetMethod
extension WritingTimeDiaryViewController {
    @objc func keyboardWillShowChangeConstraint(_ sender: Notification) {
        var keyboardHeight: CGFloat = 0
        
        if let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
        updateBottomButtonsConstraints(keyboardHeight)
    }
}

// MARK: - Binding
extension WritingTimeDiaryViewController {
    private func bindingViewModel() {
        viewModel.time
            .sink { [weak self] time in
                self?.timeLabel.text = time
            }.store(in: &subscriptions)
        
        viewModel.image.sink { [weak self] image in
            self?.imageView.image = image
            self?.imageView.snp.updateConstraints {
                $0.height.equalTo(self?.imageView.image == nil ? 0 : 60)
            }
        }.store(in: &subscriptions)
        
        viewModel.date.sink { [weak self] date in
            self?.dateLineView.configureDateLabel(date: date)
        }.store(in: &subscriptions)
    }
    
    private func bindingViewProperties() {
        saveButton.tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                if self.viewModel.diary.isEmpty {
                    self.presentCantSaveAlert()
                } else {
                    self.viewModel.saveTimeDiary {
                        self.dismiss(animated: true)
                    }
                }
            }.store(in: &subscriptions)
        
        photoButton.tapPublisher
            .sink { [weak self] in
                self?.presentImagePickerActionSheet()
            }.store(in: &subscriptions)
        
        diaryTextView.textPublisher
            .sink { [weak self] diary in
                self?.viewModel.diary = diary ?? ""
                let diaryStringCount = self?.viewModel.getDiaryStringCount() ?? 0
                self?.diaryStringCountLabel.text = "\(diaryStringCount)/300"
            }.store(in: &subscriptions)
    }
}

// MARK: - ConfigureGesture
extension WritingTimeDiaryViewController {
    private func configureImageViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        
        tapGesture.tapPublisher
            .sink { [weak self] _ in
                let vc = FullPhotoViewController(image: self?.imageView.image)
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            }.store(in: &subscriptions)
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
}

// MARK: - Alert
extension WritingTimeDiaryViewController {
    private func presentImagePickerActionSheet() {
        let alert = AlertManager(style: .actionSheet).createAlert()
            .addAction(actionTytle: "사진앨범", style: .default) { [weak self] in
                self?.openAlbum()
            }
            .addAction(actionTytle: "카메라", style: .default) { [weak self] in
                self?.openCamera()
            }
            .addAction(actionTytle: "취소", style: .cancel)
        self.present(alert, animated: true)
    }
    
    private func presentDismissAlert() {
        let alert = AlertManager(title: "작성된 내용이 저장이 안됩니다", message: "작성을 종료하겠습니까?")
            .createAlert()
            .addAction(actionTytle: "확인", style: .default) { [weak self] in
                self?.dismiss(animated: true)
            }
            .addAction(actionTytle: "취소", style: .cancel)
        self.present(alert, animated: true)
    }
    
    private func presentCantSaveAlert() {
        let alert = AlertManager(message: "일기를 작성해주세요")
            .createAlert()
            .addAction(actionTytle: "확인", style: .default)
        self.present(alert, animated: true)
    }
}

// MARK: - UI
extension WritingTimeDiaryViewController {
    private func configureSubViews() {
        [dateLineView, navigationBar, timeLabel,
         diaryTextView, diaryStringCountLabel,
         imageView, photoButton, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraintsNavigationBar() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func setConstraintsOfDateLineView() {
        dateLineView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(30)
            $0.top.equalTo(navigationBar.snp.bottom)
        }
    }
    
    private func setConstraintsOfTimeLabel() {
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(dateLineView.snp.bottom).offset(5)
            $0.centerX.width.equalToSuperview()
        }
    }
    
    private func setConstraintsOfBottomButtons() {
        photoButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-5)
            $0.leading.equalToSuperview().offset(15)
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-5)
            $0.trailing.equalToSuperview().offset(-15)
        }
    }
    
    private func setConstraintsOfImageView() {
        imageView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(5)
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalTo(60)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setConstraintsOfDiaryTextView() {
        diaryTextView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(5)
            $0.bottom.equalTo(saveButton.snp.top).offset(-10)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
        }
    }
    
    private func setConstraintsOfDiaryStringCountLabel() {
        diaryStringCountLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-5)
            $0.centerX.equalToSuperview()
        }
    }
    
    func updateBottomButtonsConstraints(_ keyboardHeight: CGFloat) {
        photoButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().offset(-5 - keyboardHeight)
            $0.leading.equalToSuperview().offset(15)
            $0.size.equalTo(35)
        }
        
        saveButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().offset(-5 - keyboardHeight)
            $0.trailing.equalToSuperview().offset(-15)
            $0.size.equalTo(35)
        }
        
        diaryStringCountLabel.snp.remakeConstraints {
            $0.centerY.equalTo(saveButton.snp.centerY)
            $0.centerX.equalToSuperview()
        }
    }
}
