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
        
        return label
    }()
    
    private let passwordStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 9
        
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
            button.setImage(UIImage(systemName: "backward"), for: .normal)
        }
        button.setPreferredSymbolConfiguration(.init(pointSize: 30, weight: .regular, scale: .default), forImageIn: .normal)
        button.tintColor = .black
        
        return button
    }()
    
    // MARK: - Properties
    private var subscription = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        setKeypad()
        configureSubViews()
        setConstraintsOfKeypadVerticalStackView()
        
        bindingSelf()
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
            .sink {
                guard let num = button.titleLabel?.text else { return }
                print(num)
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
                print("delete")
            }.store(in: &subscription)
    }
}

// MARK: - UI
extension ApplicationPasswordViewController {
    private func configureSubViews() {
        [keypadVerticalStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraintsOfKeypadVerticalStackView() {
        keypadVerticalStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.height.equalTo(300)
        }
    }
}
