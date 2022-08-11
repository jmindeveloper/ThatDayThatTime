//
//  FullImageViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/11.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

final class FullPhotoViewController: UIViewController {
    
    // MARK: - ViewProperties
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    init(image: UIImage?) {
        imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSubViews()
        setConstraintsOfImageView()
        setConstraintsOfDismissButton()
        
        configureDismissButtonGesture()
    }
    
}

// MARK: - ConfigureGesture
extension FullPhotoViewController {
    private func configureDismissButtonGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.tapPublisher
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }.store(in: &subscriptions)
        
        dismissButton.addGestureRecognizer(tapGesture)
    }
}

// MARK: - UI
extension FullPhotoViewController {
    private func configureSubViews() {
        [imageView, dismissButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraintsOfImageView() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setConstraintsOfDismissButton() {
        dismissButton.snp.makeConstraints {
            $0.size.equalTo(40)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview().offset(-17)
        }
    }
}
