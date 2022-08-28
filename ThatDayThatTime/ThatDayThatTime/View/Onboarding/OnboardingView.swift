//
//  OnboardingView.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/28.
//

import UIKit
import Combine
import SnapKit
import CombineCocoa

final class OnboardingView: UIView {
    
    // MARK: - ViewProperties
    private let pageContol: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 10
        
        return control
    }()
    
    private lazy var onboardingCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionView.onboardingLayout())
        collectionView.dataSource = self
        collectionView.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: OnboardingCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .segmentedNonSelectedColor
        button.setTitle("시작하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .semibold)
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 1
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        return button
    }()
    
    // MARK: - Properteis
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .viewBackgroundColor
        configureSubViews()
        setConstraintsOfPageControl()
        setConstraintsOfStartButton()
        setConstraintsOfOnboardingCollectionView()
        
        bindingSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Binding
extension OnboardingView {
    private func bindingSelf() {
        startButton.tapPublisher
            .sink { [weak self] in
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self?.alpha = 0
                } completion: { _ in
                    self?.removeFromSuperview()
                }
            }.store(in: &subscriptions)
    }
}

// MARK: - UI
extension OnboardingView {
    private func configureSubViews() {
        [onboardingCollectionView, pageContol, startButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setConstraintsOfOnboardingCollectionView() {
        onboardingCollectionView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(30)
            $0.width.equalToSuperview().multipliedBy(0.85)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(onboardingCollectionView.snp.width).multipliedBy(1.3)
        }
    }
    
    private func setConstraintsOfPageControl() {
        pageContol.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(onboardingCollectionView.snp.bottom).offset(-9)
        }
    }
    
    private func setConstraintsOfStartButton() {
        startButton.snp.makeConstraints {
            $0.width.equalTo(200)
            $0.height.equalTo(60)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
    }
}

extension OnboardingView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as? OnboardingCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
}
