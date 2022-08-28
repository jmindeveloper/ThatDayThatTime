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
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    private let currentHeight: CGFloat = UIScreen.main.bounds.height
    private let maximumHeight: CGFloat = UIScreen.main.bounds.height
    
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
        view.backgroundColor = .clear
        configureSubViews()
        setConstraintsOfImageView()
        setConstraintsOfContainerView()
        
        configurePanGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentContainerAnimation()
    }
}

// MARK: - ConfigureGesture
extension FullPhotoViewController {
    private func configurePanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: nil)
        panGesture.panPublisher
            .sink { [weak self] pg in
                guard let self = self else { return }
                let panOringin = pg.translation(in: self.view)
                let newHeight = self.currentHeight - panOringin.y
                
                switch pg.state {
                case .changed:
                    if newHeight < self.maximumHeight {
                        self.containerView.snp.updateConstraints {
                            $0.height.equalTo(newHeight)
                        }
                    }
                case .ended:
                    if newHeight < self.maximumHeight {
                        self.dismissAnimation()
                    }
                default: break
                }
                
            }.store(in: &subscriptions)
        
        view.addGestureRecognizer(panGesture)
    }
}

// MARK: - Animation
extension FullPhotoViewController {
    private func presentContainerAnimation() {
        containerView.snp.updateConstraints {
            $0.height.equalTo(currentHeight)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) { [weak self] in
            self?.view.layoutIfNeeded()
            self?.dimmedView.alpha = 0.6
        }
    }
    
    private func dismissAnimation() {
        containerView.snp.updateConstraints {
            $0.height.equalTo(0)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) { [weak self] in
            self?.dimmedView.alpha = 0
            self?.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}

// MARK: - UI
extension FullPhotoViewController {
    private func configureSubViews() {
        [dimmedView, containerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        containerView.addSubview(imageView)
    }
    
    private func setConstraintsOfContainerView() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0)
        }
    }
    
    private func setConstraintsOfImageView() {
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(containerView)
            $0.height.equalTo(view.snp.height)
        }
    }
}
