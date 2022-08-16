//
//  SearchDiaryCollectinViewHeader.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import Foundation
import UIKit

final class SearchDiaryCollectinViewHeader: UICollectionReusableView {
    
    static let identifier = "SearchDiaryCollectinViewHeader"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
