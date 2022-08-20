//
//  SettingViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit
import Combine
import LocalAuthentication

final class SettingViewController: UIViewController {
    
    // MARK: - ViewProperties
    private lazy var settingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .viewBackgroundColor
        tableView.register(SettingSwitchTableViewCell.self, forCellReuseIdentifier: SettingSwitchTableViewCell.identifier)
        tableView.register(SettingAccessoryTableViewCell.self, forCellReuseIdentifier: SettingAccessoryTableViewCell.identifier)
        
        return tableView
    }()
    
    // MARK: - Properties
    private let viewModel = SettingViewModel()
    private var subscriptions = Set<AnyCancellable>()
    private let authContext = LAContext()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "설정"
        view.backgroundColor = .viewBackgroundColor
        configureSubViews()
        setConstraintsOfSettingTableView()
        
        bindingViewModel()
        viewModel.configure()
    }
}

// MARK: - Method
extension SettingViewController {
    private func pushSettingFontViewController() {
        let vc = SettingFontViewController()
        navigationController?.pushViewController(vc)
    }
    
    private func presentSettingPasswordViewController() {
        let viewModel = ApplicationPasswordViewModel(passwordEntryStatus: .create)
        let vc = ApplicationPasswordViewController(viewModel: viewModel)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true)
    }
    
    
}

// MARK: - Binding
extension SettingViewController {
    private func bindingViewModel() {
        viewModel.updateSetting
            .sink { [weak self] in
                self?.settingTableView.reloadData()
            }.store(in: &subscriptions)
        
        viewModel.settingFont
            .sink { [weak self] in
                self?.pushSettingFontViewController()
            }.store(in: &subscriptions)
        
        viewModel.settingPassword
            .sink { [weak self] in
                self?.presentSettingPasswordViewController()
            }.store(in: &subscriptions)
        
        viewModel.settingLocalAuth
            .sink { [weak self] securityState in
                if securityState {
                    LocalAuth.localAuth {
                        self?.viewModel.setLocalAuth(state: true)
                    } noAuthority: {
                        let alert = AlertManager(
                            title: "생체인증이 불가능합니다",
                            message: "권한설정을 확인해주세요"
                        )
                            .createAlert()
                            .addAction(actionTytle: "확인", style: .default)
                        
                        self?.present(alert, animated: true)
                    }
                } else {
                    let alert = AlertManager(
                        message: "비밀번호 설정을 먼저 해주세요"
                    )
                        .createAlert()
                        .addAction(actionTytle: "확인", style: .default)
                    
                    self?.present(alert, animated: true)
                }
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
        case .accessoryCell(model: let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingAccessoryTableViewCell.identifier, for: indexPath) as? SettingAccessoryTableViewCell else { return UITableViewCell() }
            cell.configureCell(with: model)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = viewModel.sections[section]
        return section.sectionTitle
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .black
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = viewModel.sections[indexPath.section].settingCells[indexPath.row]
        
        switch model.self {
        case .accessoryCell(model: let model):
            model.handler?()
        default: break
        }
    }
}
