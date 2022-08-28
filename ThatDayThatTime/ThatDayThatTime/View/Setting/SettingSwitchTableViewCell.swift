//
//  SettingSwitchTableViewCell.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/18.
//

import UIKit
import SnapKit
import Combine

final class SettingSwitchTableViewCell: UITableViewCell {

    static let identifier = "SettingSwitchTableViewCell"
    
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
    
    private let toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        
        return toggleSwitch
    }()
    
    // MARK: - Properties
    private var handler: ((Bool) -> Void)?
    var switchPoint: ((CGPoint) -> Void)?
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubViews()
        setConstraintsOfLabelStackView()
        setConstraintsOfToggleSwitch()
        bindingSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension SettingSwitchTableViewCell {
    func configureCell(with model: SettingSwitchModel) {
        if model.description == nil {
            descriptionLabel.isHidden = true
        } else {
            descriptionLabel.text = model.description
        }
        
        titleLabel.text = model.title
        toggleSwitch.isOn = model.isOn
        handler = model.handler
        contentView.backgroundColor = .settingCellBackgroundColor
    }
    
    func switchTouchPoint() -> CGPoint {
        let origin =  UITouch().location(in: toggleSwitch)
        return CGPoint(x: abs(origin.x), y: abs(origin.y))
    }
}

// MARK: - Bidning
extension SettingSwitchTableViewCell {
    private func bindingSelf() {
        toggleSwitch.isOnPublisher
            .sink { [weak self] isOn in
                guard let self = self else {
                    return
                    
                }
                self.handler?(isOn)
                self.switchPoint?(self.switchTouchPoint())
            }.store(in: &subscriptions)
    }
}

// MARK: - UI
extension SettingSwitchTableViewCell {
    private func configureSubViews() {
        [labelStackView, toggleSwitch].forEach {
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
            $0.trailing.equalTo(toggleSwitch.snp.leading).offset(-9)
            $0.verticalEdges.equalToSuperview().inset(7)
        }
    }
    
    private func setConstraintsOfToggleSwitch() {
        toggleSwitch.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-9)
        }
    }
}
