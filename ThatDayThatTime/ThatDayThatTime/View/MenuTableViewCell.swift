//
//  MenuTableViewCell.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit
import SnapKit

final class MenuTableViewCell: UITableViewCell {
    
    static let identifier = "MenuTableViewCell"
    
    // MARK: - ViewProperties
    private let menuImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .darkGray
        
        return imageView
    }()
    
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        
        return label
    }()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .viewBackgroundColor
        configureSubViews()
        setConstraintsOfMenuImageView()
        setConstraintsOfMenuLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension MenuTableViewCell {
    func configureCell(image: UIImage?, menu: String) {
        self.menuImageView.image = image
        self.menuLabel.text = menu
    }
}

// MARK: - UI
extension MenuTableViewCell {
    private func configureSubViews() {
        [menuImageView, menuLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setConstraintsOfMenuImageView() {
        menuImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(7)
            $0.leading.equalToSuperview().offset(7)
            $0.height.equalTo(menuImageView.snp.width)
        }
    }
    
    private func setConstraintsOfMenuLabel() {
        menuLabel.snp.makeConstraints {
            $0.centerY.equalTo(menuImageView.snp.centerY)
            $0.leading.equalTo(menuImageView.snp.trailing).offset(7)
            $0.trailing.equalToSuperview().offset(-7)
        }
    }
}
