//
//  TimeDiaryWidgetBundle.swift
//  TimeDiaryWidget
//
//  Created by J_Min on 7/1/24.
//

import WidgetKit
import SwiftUI

@main
struct TimeDiaryWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimeDiaryWidget()
        TimeDiaryWidgetLiveActivity()
    }
}
