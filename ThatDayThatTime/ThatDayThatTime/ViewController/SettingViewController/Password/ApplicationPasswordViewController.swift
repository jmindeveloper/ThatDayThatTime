//
//  ApplicationPasswordViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/19.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

final class ApplicationPasswordViewController: UIViewController {
    
    // MARK: - ViewProperties
    private let passwordTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.textColor = .black
        label.text = "비밀번호 입력"
        
        return label
    }()
    
    private let passwordStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private lazy var keypadVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .semibold)
        
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        if #available(iOS 15, *) {
            button.setImage(UIImage(systemName: "delete.backward"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        }
        button.setPreferredSymbolConfiguration(.init(pointSize: 30, weight: .regular, scale: .default), forImageIn: .normal)
        button.tintColor = .black
        
        return button
    }()
    
    // MARK: - Properties
    private var subscription = Set<AnyCancellable>()
    private let viewModel: ApplicationPasswordViewModel
    
    // MARK: - LifeCycle
    init(viewModel: ApplicationPasswordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        setKeypad()
        setPasswordStackView()
        configureSubViews()
        setConstraintsOfKeypadVerticalStackView()
        setConstraintsOfPasswordStackView()
        setConstraintsOfPasswordTitleLabel()
        
        bindingSelf()
        bindingViewModel()
        
        viewModel.localAuth()
    }
}

// MARK: - Method
extension ApplicationPasswordViewController {
    private func setKeypadButton(num: Int) -> UIButton {
        let button = UIButton()
        button.setTitle(String(num), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 50)
        button.setTitleColor(.black, for: .normal)
        button.frame.size = CGSize(width: 60, height: 60)
        button.tapPublisher
            .sink { [weak self] in
                guard let num = button.titleLabel?.text else { return }
                self?.viewModel.appendPassword(num: num)
                self?.checkInputPassword()
            }.store(in: &subscription)
        
        return button
    }
    
    private func setKeypad() {
        var count = 1
        for _ in 0..<3 {
            let keypadHorizontalStackView = UIStackView()
            keypadHorizontalStackView.axis = .horizontal
            keypadHorizontalStackView.spacing = 0
            keypadHorizontalStackView.distribution = .fillEqually
            
            for _ in 0..<3 {
                let button = setKeypadButton(num: count)
                keypadHorizontalStackView.addArrangedSubview(button)
                count += 1
            }
            keypadVerticalStackView.addArrangedSubview(keypadHorizontalStackView)
        }
        let keypadHorizontalStackView = UIStackView()
        keypadHorizontalStackView.axis = .horizontal
        keypadHorizontalStackView.spacing = 0
        keypadHorizontalStackView.distribution = .fillEqually
        keypadHorizontalStackView.addArrangedSubview(dismissButton)
        keypadHorizontalStackView.addArrangedSubview(setKeypadButton(num: 0))
        keypadHorizontalStackView.addArrangedSubview(deleteButton)
        keypadVerticalStackView.addArrangedSubview(keypadHorizontalStackView)
    }
    
    private func setPasswordStackView() {
        for _ in 0..<4 {
            let view = UIImageView()
            view.image = UIImage(systemName: "circle")
            view.tintColor = .darkGray
            passwordStackView.addArrangedSubview(view)
        }
    }
    
    private func checkInputPassword() {
        passwordStackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let imageView = view as? UIImageView else { return }
            if index < viewModel.inputPassword.count {
                imageView.image = UIImage(systemName: "circle.fill")
            } else {
                imageView.image = UIImage(systemName: "circle")
            }
        }
    }
    
    private func presentTimeDiaryViewController() {
        let coreDataManager = CoreDataManager()
        let timeDiaryViewModel = TimeDiaryViewModel(coreDataManager: coreDataManager)
        let vc = UINavigationController(rootViewController: TimeDiaryViewController(viewModel: timeDiaryViewModel))
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        
        present(vc, animated: true)
    }
    
    private func passwordWrongAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.03
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: passwordStackView.center.x - 4.0, y: passwordStackView.center.y)
        animation.toValue = CGPoint(x: passwordStackView.center.x + 4.0, y: passwordStackView.center.y)
        passwordStackView.layer.add(animation, forKey: "position")
    }
}

// MARK: - Binding
extension ApplicationPasswordViewController {
    private func bindingSelf() {
        dismissButton.tapPublisher
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }.store(in: &subscription)
        
        deleteButton.tapPublisher
            .sink { [weak self] in
                self?.viewModel.deletePassword()
                self?.checkInputPassword()
            }.store(in: &subscription)
    }
    
    private func bindingViewModel() {
        viewModel.doneInputPassword
            .sink { [weak self] status, isValid in
                switch status {
                case .create:
                    self?.checkInputPassword()
                    self?.passwordTitleLabel.text = "비밀번호 확인"
                case .check:
                    if isValid {
                        self?.dismiss(animated: true)
                    } else {
                        self?.passwordWrongAnimation()
                        self?.checkInputPassword()
                    }
                case .run:
                    if isValid {
                        self?.presentTimeDiaryViewController()
                    } else {
                        self?.passwordWrongAnimation()
                        self?.checkInputPassword()
                    }
                }
            }.store(in: &subscription)
        
        viewModel.showLocalAuth
            .sink { [weak self] in
                LocalAuth.localAuth {
                    self?.presentTimeDiaryViewController()
                } noAuthority: {
                    let alert = AlertManager(
                        title: "생체인증이 불가능합니다",
                        message: "권한설정을 확인해주세요"
                    )
                        .createAlert()
                        .addAction(actionTytle: "확인", style: .default)
                    
                    self?.present(alert, animated: true)
                }

            }.store(in: &subscription)
    }
}

// MARK: - UI
extension ApplicationPasswordViewController {
    private func configureSubViews() {
        [passwordTitleLabel, passwordStackView,
         keypadVerticalStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraintsOfPasswordTitleLabel() {
        passwordTitleLabel.snp.makeConstraints {
            $0.bottom.equalTo(passwordStackView.snp.top).offset(-15)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setConstraintsOfPasswordStackView() {
        passwordStackView.snp.makeConstraints {
            $0.bottom.equalTo(keypadVerticalStackView.snp.top).offset(-30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
        }
    }
    
    private func setConstraintsOfKeypadVerticalStackView() {
        keypadVerticalStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-35)
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(300)
        }
    }
}
