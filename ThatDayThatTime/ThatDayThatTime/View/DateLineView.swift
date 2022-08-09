//
//  DateLineView.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import UIKit
import SnapKit

final class DateLineView: UIView {
    
    // MARK: - ViewProperties
    private let leftLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        
        return view
    }()
    
    private let rightLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .viewBackgroundColor
        label.textAlignment = .center
        label.textColor = .lightGray
        label.isUserInteractionEnabled = false
        
        return label
    }()
    
    // MARK: - LifeCycle
    init() {
        super.init(frame: .zero)
        configureSubViews()
        setConstraintsOfDateLabel()
        setConstraintsOfLeftLine()
        setConstraintsOfRightLine()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureDateLabel(date: String) {
        dateLabel.text = date
    }
    
}

// MARK: - UI
extension DateLineView {
    private func configureSubViews() {
        [leftLine, rightLine, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setConstraintsOfLeftLine() {
        leftLine.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel.snp.centerY)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(dateLabel.snp.leading).offset(-8)
            $0.height.equalTo(1)
        }
    }

    private func setConstraintsOfRightLine() {
        rightLine.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(dateLabel.snp.trailing).offset(8)
            $0.height.equalTo(1)
        }
    }
    
    private func setConstraintsOfDateLabel() {
        dateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

}
