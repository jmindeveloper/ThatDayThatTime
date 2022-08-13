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
//        ImageCacheManager.shared.storeImage((diary?.id)!, image: image)
        return UIImage(data: data)
    }
    
    func resize(scale: CGFloat) -> UIImage {
        let data = self.pngData()! as CFData
        let imageSource = CGImageSourceCreateWithData(data, nil)!
        let maxPixel = max(self.size.width, self.size.height) * scale
        let downSampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ] as CFDictionary

        let downSampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downSampleOptions)!
        let newImage = UIImage(cgImage: downSampledImage)
        
        return newImage
    }
}
