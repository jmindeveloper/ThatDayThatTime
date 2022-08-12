//
//  TimeDiaryCollectionViewCell.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/10.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

final class TimeDiaryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TimeDiaryCollectionViewCell"
    
    // MARK: - ViewProperties
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        
        return label
    }()
    
    private let connectionTopLine: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        
        return view
    }()
    
    private let connectionBottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        
        return view
    }()
    
    private let connectionCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        
        return label
    }()
    
    // MARK: - Properties
    var tapImage: (() -> Void)?
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .viewBackgroundColor
        configureSubViews()
        setConstraintsOfConnectionCircle()
        setConstraintsOfConnectionTopLine()
        setConstraintsOfConnectionBottomLine()
        setConstraintsOfTimeLabel()
        setConstraintsOfImageView()
        setConstraintsOfContentLabel()
        
        configureImageViewGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Method
extension TimeDiaryCollectionViewCell {
    func configureCell(with diary: TimeDiary, isFirst: Bool, isLast: Bool) {
        timeLabel.text = diary.time
        contentLabel.text = diary.content
        imageView.image = UIImage.getImage(with: diary)
        imageView.snp.updateConstraints {
            $0.height.equalTo(imageView.image == nil ? 0 : 60)
        }
        
        if isFirst {
            connectionTopLine.isHidden = true
        } else {
            connectionTopLine.isHidden = false
        }
        
        if isLast {
            connectionBottomLine.isHidden = true
        } else {
            connectionBottomLine.isHidden = false
        }
    }
}

// MARK: - ConfigureGesture
extension TimeDiaryCollectionViewCell {
    private func configureImageViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.tapPublisher
            .sink { [weak self] _ in
                self?.tapImage?()
            }.store(in: &subscriptions)
        
        imageView.addGestureRecognizer(tapGesture)
    }
}

// MARK: - UI
extension TimeDiaryCollectionViewCell {
    private func configureSubViews() {
        [timeLabel, connectionTopLine, connectionBottomLine,
         connectionCircle, imageView, contentLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setConstraintsOfConnectionCircle() {
        connectionCircle.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(15)
            $0.size.equalTo(10)
        }
        connectionCircle.layer.cornerRadius = 5
    }
    
    private func setConstraintsOfConnectionTopLine() {
        connectionTopLine.snp.makeConstraints {
            $0.centerX.equalTo(connectionCircle.snp.centerX)
            $0.bottom.equalTo(connectionCircle.snp.centerY)
            $0.width.equalTo(3)
            $0.top.equalToSuperview()
        }
    }
    
    private func setConstraintsOfConnectionBottomLine() {
        connectionBottomLine.snp.makeConstraints {
            $0.centerX.equalTo(connectionCircle.snp.centerX)
            $0.top.equalTo(connectionCircle.snp.centerY)
            $0.width.equalTo(3)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setConstraintsOfTimeLabel() {
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(connectionCircle.snp.trailing).offset(15)
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalTo(connectionCircle.snp.centerY)
        }
    }
    
    private func setConstraintsOfImageView() {
        imageView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(5)
            $0.width.equalTo(timeLabel.snp.width)
            $0.height.equalTo(60)
            $0.centerX.equalTo(timeLabel.snp.centerX)
        }
    }
    
    private func setConstraintsOfContentLabel() {
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(5)
            $0.width.equalTo(timeLabel.snp.width)
            $0.centerX.equalTo(timeLabel.snp.centerX)
            $0.bottom.equalToSuperview().offset(-15)
        }
    }
}
