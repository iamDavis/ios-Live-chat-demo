//
//  Extensions.swift
//  gameofchats
//
//  Created by zeyu deng on 2017/12/26.
//  Copyright © 2017年 zeyu deng. All rights reserved.//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageUsingUrlString(urlString: String){
        
        self.image = nil
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, Error) in
            if Error != nil {
                print(Error)
                return
            }
            DispatchQueue.main.async {
                if  let downloadedImage = UIImage(data:data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
                
                print("Image fetched")
            }
            
        }).resume()
    }
    
}
