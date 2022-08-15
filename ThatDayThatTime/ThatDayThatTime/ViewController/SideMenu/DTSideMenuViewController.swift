//
//  DTSideMenuViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit
import SnapKit

final class DTSideMenuViewController: UIViewController {
    
    enum MenuSelectedViewController: Int {
        case search = 0, gather, setting
        
        var viewController: UIViewController {
            switch self {
            case .search:
                return SearchDiaryViewController()
            case .gather:
                return GatherDiaryViewController()
            case .setting:
                return SettingViewController()
            }
        }
    }
    
    // MARK: - ViewProperties
    private lazy var menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .viewBackgroundColor
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: MenuTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    // MARK: - Properties
    private let tableViewItems = [
        (UIImage(systemName: "magnifyingglass"), "검색"),
        (UIImage(systemName: "book.closed"), "모아보기"),
        (UIImage(systemName: "gearshape"), "설정")
    ]
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        configureSubViews()
        setConstraintsOfMenuTableView()
    }
    
}

// MARK: - UI
extension DTSideMenuViewController {
    private func configureSubViews() {
        view.addSubview(menuTableView)
    }
    
    private func setConstraintsOfMenuTableView() {
        menuTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension DTSideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.identifier) as? MenuTableViewCell else {
            return UITableViewCell()
        }
        
        let item = tableViewItems[indexPath.row]
        cell.configureCell(image: item.0, menu: item.1)
        
        return cell
    }
}

extension DTSideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let vc = MenuSelectedViewController(rawValue: indexPath.row)?.viewController else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
