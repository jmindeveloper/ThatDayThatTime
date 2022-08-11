//
//  UIImage+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/11.
//

import UIKit

extension UIImage {
    static func getImage(to data: Data?) -> UIImage? {
        guard let data = data else {
            return nil
        }

        return UIImage(data: data)
    }
}
