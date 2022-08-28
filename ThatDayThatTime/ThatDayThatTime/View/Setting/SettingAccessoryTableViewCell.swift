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
        let label = UILabel()
        label.textColor = .black
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 11)
        
        return label
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let accessory: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .darkGray
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubViews()
        setConstraintsOfLabelStackView()
        setConstraintsOfAccessory()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension SettingAccessoryTableViewCell {
    func configureCell(with model: SettingAccessoryModel) {
        if model.description == nil {
            descriptionLabel.isHidden = true
        } else {
            descriptionLabel.text = model.description
        }
        
        titleLabel.text = model.title
        accessory.image = model.accessory
        contentView.backgroundColor = .settingCellBackgroundColor
    }
}

// MARK: - UI
extension SettingAccessoryTableViewCell {
    private func configureSubViews() {
        [labelStackView, accessory].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        [titleLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            labelStackView.addArrangedSubview($0)
        }
    }
    
    private func setConstraintsOfLabelStackView() {
        labelStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(9)
            $0.trailing.equalTo(accessory.snp.leading).offset(-9)
            $0.verticalEdges.equalToSuperview().inset(7)
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
