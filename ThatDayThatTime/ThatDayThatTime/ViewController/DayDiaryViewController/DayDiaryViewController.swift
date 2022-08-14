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
        dateLineView.configureDateLabel(date: String.getDate())
        
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
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    init(viewModel: DayDiaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        configureSubViews()
        setConstraintsOfDateLineView()
        setConstraintsOfImageView()
        setConstraintsOfDiaryTextView()
        
        bindingViewModel()
        viewModel.getDiary()
    }
    
}

// MARK: - Method
extension DayDiaryViewController {
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
}

// MARK: - Binding
extension DayDiaryViewController {
    private func bindingViewModel() {
        viewModel.notExistDayDiary
            .sink { [weak self] in
                self?.presentWritingDayDiaryViewController()
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
