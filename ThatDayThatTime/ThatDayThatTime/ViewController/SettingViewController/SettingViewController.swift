//
//  SettingViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit
import Combine

final class SettingViewController: UIViewController {
    
    // MARK: - ViewProperties
    private lazy var settingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .viewBackgroundColor
        tableView.register(SettingSwitchTableViewCell.self, forCellReuseIdentifier: SettingSwitchTableViewCell.identifier)
        tableView.register(SettingNavigationTableViewCell.self, forCellReuseIdentifier: SettingNavigationTableViewCell.identifier)
        
        return tableView
    }()
    
    // MARK: - Properties
    private let viewModel = SettingViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        configureSubViews()
        setConstraintsOfSettingTableView()
        
        bindingViewModel()
        viewModel.configure()
    }
}

// MARK: - Binding
extension SettingViewController {
    private func bindingViewModel() {
        viewModel.updateSetting
            .sink { [weak self] in
                self?.settingTableView.reloadData()
            }.store(in: &subscriptions)
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
        viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = viewModel.sections[section]
        return section.settingCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.sections[indexPath.section].settingCells[indexPath.row]
        
        switch model.self {
        case .switchCell(model: let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingSwitchTableViewCell.identifier, for: indexPath) as? SettingSwitchTableViewCell else { return UITableViewCell() }
            cell.configureCell(with: model)
            
            return cell
        case .navigationCell(model: let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingNavigationTableViewCell.identifier, for: indexPath) as? SettingNavigationTableViewCell else { return UITableViewCell() }
            cell.configureCell(with: model)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = viewModel.sections[section]
        return section.sectionTitle
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = viewModel.sections[indexPath.section].settingCells[indexPath.row]
        
        switch model.self {
        case .navigationCell(model: let model):
            model.handler?()
        default: break
        }
    }
}
