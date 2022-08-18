//
//  SettingFontViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/18.
//

import UIKit
import SnapKit
import Combine

final class SettingFontViewController: UIViewController {
    
    private let fontPreview: UIView = {
        let view = UIView()
        view.backgroundColor = .settingCellBackgroundColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let fontPreviewLabel: UILabel = {
        let label = UILabel()
        label.font = UserSettingManager.shared.getFont().font
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = """
        
        안녕하세요!
        그날 그시간
        0123456789
        abcdefghijklmnopqrstuvwxyz
        ABCDEFGHIJKLMNOPQRSTUVWXYZ
        가나다라마바사아자차카타파하
        
        """
        
        return label
    }()
    
    private lazy var fontTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .viewBackgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingAccessoryTableViewCell.self, forCellReuseIdentifier: SettingAccessoryTableViewCell.identifier)
        
        return tableView
    }()
    
    // MARK: - Properties
    private let viewModel = SettingFontViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "폰트"
        view.backgroundColor = .viewBackgroundColor
        configureSubViews()
        setConstraintsOfFontPreviewTextView()
        setConstraintsOfFontPreviewLabel()
        setConstraintsOfFontTableView()
        
        bindingViewModel()
    }
}

// MARK: - Binding
extension SettingFontViewController {
    private func bindingViewModel() {
        viewModel.updateFont
            .sink { [weak self] in
                self?.fontTableView.reloadData()
                self?.fontPreviewLabel.font = UserSettingManager.shared.getFont().font
            }.store(in: &subscriptions)
    }
}

// MARK: - UI
extension SettingFontViewController {
    private func configureSubViews() {
        [fontPreview, fontPreviewLabel, fontTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraintsOfFontPreviewTextView() {
        fontPreview.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(200)
        }
    }
    
    private func setConstraintsOfFontPreviewLabel() {
        fontPreviewLabel.snp.makeConstraints {
            $0.center.equalTo(fontPreview.snp.center)
        }
    }
    
    private func setConstraintsOfFontTableView() {
        fontTableView.snp.makeConstraints {
            $0.top.equalTo(fontPreview.snp.bottom).offset(20)
            $0.width.equalTo(fontPreview.snp.width)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension SettingFontViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fontModels.settingCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingAccessoryTableViewCell.identifier, for: indexPath) as? SettingAccessoryTableViewCell else {
            return UITableViewCell()
        }
        let model = viewModel.fontModels.settingCells[indexPath.row]
        if case .accessoryCell(model: let model) = model {
            cell.configureCell(with: model)
            return cell
        }
        
        return UITableViewCell()
    }
}

extension SettingFontViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.changeFont(fontIndex: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
