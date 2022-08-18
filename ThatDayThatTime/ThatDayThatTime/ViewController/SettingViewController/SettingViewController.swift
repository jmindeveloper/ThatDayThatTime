//
//  SettingViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit

final class SettingViewController: UIViewController {
    
    private lazy var settingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .viewBackgroundColor
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        configureSubViews()
        setConstraintsOfSettingTableView()
    }
}

// MARK: - UI
extension SettingViewController {
    private func configureSubViews() {
        settingTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingTableView)
    }
    
    private func setConstraintsOfSettingTableView() {
        settingTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.backgroundColor = .settingCellBackgroundColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "설정"
        case 1: return "보안"
        default: return nil
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
