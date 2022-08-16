//
//  GatherDiaryViewController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit

final class GatherDiaryViewController: UIViewController {
    
    // MARK: - ViewProperties
    private lazy var diaryCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionView.diaryLayout(supplementaryItems: [UICollectionView.diaryHeader()]))
        collectionView.backgroundColor = .viewBackgroundColor
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    private lazy var segmentedCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionView.segmentedLayout())
        collectionView.backgroundColor = .viewBackgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
    }
    
}

// MARK: - UICollectionViewDataSource
extension GatherDiaryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
extension GatherDiaryViewController: UICollectionViewDelegate {
    
}
