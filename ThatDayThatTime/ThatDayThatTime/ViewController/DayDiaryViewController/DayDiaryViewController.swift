//
//  DayDiaryViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/14.
//

import UIKit
import Combine

final class DayDiaryViewController: UIViewController {
    
    // MARK: - ViewProperties
    private let dateLineView: DateLineView = {
        let dateLineView = DateLineView()
        
        return dateLineView
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
        textView.textColor = .black
        textView.configure()
        textView.isEditable = false
        
        return textView
    }()
    
    // MARK: - Properties
    private let viewModel: DayDiaryViewModel
    private let isCanEdit: Bool
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    init(viewModel: DayDiaryViewModel, isCanEdit: Bool) {
        self.viewModel = viewModel
        self.isCanEdit = isCanEdit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        if isCanEdit {
            configureNavigation()
        }
        configureSubViews()
        setConstraintsOfDateLineView()
        setConstraintsOfImageView()
        setConstraintsOfDiaryTextView()
        
        bindingViewModel()
        viewModel.getDiary()
        
        configureImageViewGesture()
    }
}

// MARK: - Method
extension DayDiaryViewController {
    private func configureNavigation() {
        let editDayDiaryButton = UIBarButtonItem(
            image: UIImage(systemName: "pencil"),
            style: .plain,
            target: self,
            action: nil
        )
        editDayDiaryButton.tapPublisher
            .sink { [weak self] in
                if let diary = self?.viewModel.dayDiary {
                    self?.presentWritingDayDiaryViewController(with: diary)
                } else {
                    self?.presentWritingDayDiaryViewController()
                }
            }.store(in: &subscriptions)
        
        navigationItem.rightBarButtonItem = editDayDiaryButton
    }
    
    private func presentWritingDayDiaryViewController() {
        let viewModel = WritingDayDiaryViewModel(
            date: viewModel.date,
            coreDataManager: viewModel.coreDataManager
        ) 
        
        let vc = WritingDayDiaryViewController(viewModel: viewModel)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true)
    }
    
    private func presentWritingDayDiaryViewController(with diary: DayDiary) {
        let viewModel = WritingDayDiaryViewModel(
            dayDiary: diary,
            coreDataManager: viewModel.coreDataManager
        )
        
        let vc = WritingDayDiaryViewController(viewModel: viewModel)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true)
    }
}

// MARK: - ConfigureGesture
extension DayDiaryViewController {
    private func configureImageViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        
        tapGesture.tapPublisher
            .sink { [weak self] _ in
                guard let id = self?.viewModel.dayDiary?.id else { return }
                self?.viewModel.getFullSizeImage(id: id)
            }.store(in: &subscriptions)
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
}

// MARK: - Binding
extension DayDiaryViewController {
    private func bindingViewModel() {
        viewModel.notExistDayDiary
            .sink { [weak self] in
                guard let self = self else { return }
                self.presentWritingDayDiaryViewController()
                self.dateLineView.configureDateLabel(date: self.viewModel.date)
            }.store(in: &subscriptions)
        
        viewModel.existDayDiary
            .sink { [weak self] diary in
                guard let self = self else { return }
                self.diaryTextView.text = diary.content
                self.imageView.image = UIImage.getImage(data: diary.image)
                self.imageView.snp.updateConstraints {
                    $0.height.equalTo(self.imageView.image == nil ? 0 : 60)
                }
                self.dateLineView.configureDateLabel(date: self.viewModel.date)
            }.store(in: &subscriptions)
        
        viewModel.updateFullSizeImage
            .sink { [weak self] image in
                let vc = FullPhotoViewController(image: image)
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            }.store(in: &subscriptions)
    }
}

// MARK: - UI
extension DayDiaryViewController {
    private func configureSubViews() {
        [dateLineView, imageView, diaryTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraintsOfDateLineView() {
        dateLineView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(30)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setConstraintsOfDiaryTextView() {
        diaryTextView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(5)
            $0.bottom.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
        }
    }
    
    private func setConstraintsOfImageView() {
        imageView.snp.makeConstraints {
            $0.top.equalTo(dateLineView.snp.bottom).offset(5)
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalTo(60)
            $0.centerX.equalToSuperview()
        }
    }
}
