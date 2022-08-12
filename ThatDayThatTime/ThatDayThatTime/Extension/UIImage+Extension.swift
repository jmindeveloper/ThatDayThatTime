//
//  UIImage+Extension.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/11.
//

import UIKit

extension UIImage {
    static func getImage(with diary: Diary?) -> UIImage? {
        
        guard let data = diary?.image else {
            return nil
        }
        
        if let image = ImageCacheManager.shared.getImage((diary?.id)!) {
            return image
        }
        
        let image = UIImage(data: data)!
        ImageCacheManager.shared.storeImage((diary?.id)!, image: image)
        return UIImage(data: data)
    }
}
