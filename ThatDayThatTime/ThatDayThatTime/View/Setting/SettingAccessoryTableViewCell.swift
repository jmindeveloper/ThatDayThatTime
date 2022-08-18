//
//  SettingNavigationTableViewCell.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/18.
//

import UIKit

final class SettingAccessoryTableViewCell: UITableViewCell {
    
    static let identifier = "SettingNavigationTableViewCell"
    
    // MARK: - ViewProperties
    private let titleLabel: UILabel = {
        let lable = UILabel()
        
        return lable
    }()
    
    private let accessory: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .darkGray
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubViews()
        setConstraintsOfTitleLabel()
        setConstraintsOfAccessory()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension SettingAccessoryTableViewCell {
    func configureCell(with model: SettingAccessoryModel) {
        titleLabel.text = model.title
        accessory.image = model.accessory
        contentView.backgroundColor = .settingCellBackgroundColor
    }
}

// MARK: - UI
extension SettingAccessoryTableViewCell {
    private func configureSubViews() {
        [titleLabel, accessory].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setConstraintsOfTitleLabel() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(9)
            $0.trailing.equalTo(accessory.snp.leading).offset(-9)
        }
    }
    
    private func setConstraintsOfAccessory() {
        accessory.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-15)
            $0.width.equalTo(15)
            $0.height.equalTo(20)
        }
    }
}
