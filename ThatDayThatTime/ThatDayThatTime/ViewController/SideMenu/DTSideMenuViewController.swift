//
//  DTSideMenuViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit
import SnapKit

final class DTSideMenuViewController: UIViewController {
    
    enum MenuItem: Int {
        case search = 0, gather, setting
        
        var viewController: UIViewController {
            switch self {
            case .search:
                let searchDiaryViewModel = SearchDiaryViewModel(coreDataManager: CoreDataManager())
                return SearchDiaryViewController(viewModel: searchDiaryViewModel)
            case .gather:
                return GatherDiaryViewController()
            case .setting:
                return SettingViewController()
            }
        }
        
        var title: String {
            switch self {
            case .search:
                return "검색"
            case .gather:
                return "모아보기"
            case .setting:
                return "설정"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .search:
                return UIImage(systemName: "magnifyingglass")
            case .gather:
                if #available(iOS 14, *) {
                    return UIImage(systemName: "book.closed")
                } else {
                    return UIImage(systemName: "book")
                }
            case .setting:
                if #available(iOS 14, *) {
                    return UIImage(systemName: "gearshape")
                } else {
                    return UIImage(systemName: "gear")
                }
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
        
        guard let item = MenuItem(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        cell.configureCell(image: item.image, menu: item.title)
        
        return cell
    }
}

extension DTSideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let vc = MenuItem(rawValue: indexPath.row)?.viewController else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
