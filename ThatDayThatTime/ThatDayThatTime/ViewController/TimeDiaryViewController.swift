//
//  TimeDiaryViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/08.
//

import UIKit
import SnapKit

final class TimeDiaryViewController: UIViewController {
    
    // MARK: - ViewProperties
    private lazy var dateLineView: DateLineView = {
        let view = DateLineView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateLineViewTapped))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    private lazy var calendar: DTCalendar = {
        let calendar = DTCalendar()
        calendar.bindingSelectedDate { [weak self] date in
            self?.dateLineView.configureDateLabel(date: date)
        }
        
        return calendar
    }()
    
    private lazy var timeDiaryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .red
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    // MARK: - Properties
    private var calendarHidden = true
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        configureSubViews()
        setConstraintsOfDateLineView()
        setConstraintsOfCalendar()
        setConstraintsOfTimeDiaryCollectionView()
    }
}

// MARK: - TargetMethod
extension TimeDiaryViewController {
    @objc private func dateLineViewTapped() {
        calendarHidden.toggle()
        calendar.snp.updateConstraints {
            $0.width.equalToSuperview()
            $0.top.equalTo(dateLineView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.height.equalTo(calendarHidden ? 0 : 300)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.calendar.bottomLineHidden()
        }
    }
}

// MARK: - UI
extension TimeDiaryViewController {
    private func configureSubViews() {
        [dateLineView, calendar, timeDiaryCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraintsOfDateLineView() {
        dateLineView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(30)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setConstraintsOfCalendar() {
        calendar.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.equalTo(dateLineView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.height.equalTo(0)
        }
    }
    
    private func setConstraintsOfTimeDiaryCollectionView() {
        timeDiaryCollectionView.snp.makeConstraints {
            $0.top.equalTo(calendar.snp.bottom).offset(3)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TimeDiaryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
extension TimeDiaryViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TimeDiaryViewController: UICollectionViewDelegateFlowLayout {
    
}
