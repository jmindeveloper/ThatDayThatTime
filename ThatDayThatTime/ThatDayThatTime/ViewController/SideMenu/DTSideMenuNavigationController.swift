//
//  DTSideMenuNavigationController.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit
import SideMenu

final class DTSideMenuNavigationController: SideMenuNavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftSide = true
        presentDuration = 0.7
        dismissDuration = 0.7
        presentationStyle = .menuSlideIn
        menuWidth = view.frame.width * 0.45
        presentationStyle.onTopShadowColor = .black
        presentationStyle.onTopShadowOpacity = 0.1
        presentationStyle.onTopShadowRadius = 1
        presentationStyle.onTopShadowOffset = CGSize(width: 3, height: 0)
    }
}
