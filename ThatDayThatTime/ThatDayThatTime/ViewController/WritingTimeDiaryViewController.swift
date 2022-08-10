//
//  WritingTimeDiaryViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/10.
//

import UIKit
import Combine
import CombineCocoa

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
        dateLineView.configureDateLabel(date: "2022년 8월 10일 수요일")
        
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
        imageView.image = UIImage(systemName: "person.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let diaryTextView: UITextView = {
        let textView = UITextView()
        textView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        textView.font = .systemFont(ofSize: 17)
        textView.becomeFirstResponder()
        textView.backgroundColor = .viewBackgroundColor
        textView.configure()
        
        return textView
    }()
    
    private let diaryStringCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "0/300"
        
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
                self?.dismiss(animated: true)
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
        }
        
        saveButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().offset(-5 - keyboardHeight)
            $0.trailing.equalToSuperview().offset(-15)
        }
        
        diaryStringCountLabel.snp.remakeConstraints {
            $0.bottom.equalToSuperview().offset(-5 - keyboardHeight)
            $0.centerX.equalToSuperview()
        }
    }
}
