//
//  MoveDayDiaryView.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/14.
//

import UIKit
import SnapKit

final class MoveDayDiaryView: UIView {
    
    // MARK: - ViewProperties
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "하루의 기록"
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        
        return label
    }()
    
    private let indicatorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .darkGray
        
        return imageView
    }()
    
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubViews()
        setConstraintsOfDateLabel()
        setConstraintsOfDescriptionLabel()
        setConstraintsOfIndicatorImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension MoveDayDiaryView {
    func cofigureDateLabel(date: String) {
        dateLabel.text = date
    }
}

// MARK: - UI
extension MoveDayDiaryView {
    private func configureSubViews() {
        [dateLabel, descriptionLabel, indicatorImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setConstraintsOfDateLabel() {
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(7)
            $0.trailing.equalTo(indicatorImageView.snp.leading).offset(-10)
        }
    }
    
    private func setConstraintsOfDescriptionLabel() {
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(7)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(indicatorImageView.snp.leading).offset(-10)
        }
    }
    
    private func setConstraintsOfIndicatorImageView() {
        indicatorImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-17)
            $0.width.equalTo(15)
            $0.height.equalTo(20)
        }
    }
}
