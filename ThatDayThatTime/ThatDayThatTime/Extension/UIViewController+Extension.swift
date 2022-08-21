//
//  UIViewController+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/21.
//

import UIKit
import Combine
import Toast

extension UIViewController {
    func respondsToast() -> AnyCancellable {
        return ToastMessageManager.toast
            .sink { [weak self] message in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.view.makeToast(message)
                }
            }
    }
}
