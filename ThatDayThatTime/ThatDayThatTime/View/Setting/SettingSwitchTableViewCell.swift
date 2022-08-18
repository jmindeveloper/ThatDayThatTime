//
//  SettingSwitchTableViewCell.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/18.
//

import UIKit
import SnapKit

final class SettingSwitchTableViewCell: UITableViewCell {

    static let identifier = "SettingSwitchTableViewCell"
    
    // MARK: - ViewProperties
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        
        return toggleSwitch
    }()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubViews()
        setConstraintsOfTitleLabel()
        setConstraintsOfToggleSwitch()
        contentView.backgroundColor = .settingCellBackgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension SettingSwitchTableViewCell {
    func configureCell(with model: SettingSwitchModel) {
        titleLabel.text = model.title
        toggleSwitch.isOn = model.isOn
    }
}

// MARK: - UI
extension SettingSwitchTableViewCell {
    private func configureSubViews() {
        [titleLabel, toggleSwitch].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setConstraintsOfTitleLabel() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(9)
            $0.trailing.equalTo(toggleSwitch.snp.leading).offset(-9)
        }
    }
    
    private func setConstraintsOfToggleSwitch() {
        toggleSwitch.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-9)
        }
    }
}
