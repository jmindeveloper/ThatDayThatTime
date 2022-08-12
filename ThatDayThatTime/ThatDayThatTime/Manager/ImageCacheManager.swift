//
//  ImageCacheManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/11.
//

import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() { }
    
    func storeImage(_ id: String, image: UIImage) {
        cache.setObject(image, forKey: id as NSString)
    }
    
    func getImage(_ id: String) -> UIImage? {
        return cache.object(forKey: id as NSString)
    }
}
