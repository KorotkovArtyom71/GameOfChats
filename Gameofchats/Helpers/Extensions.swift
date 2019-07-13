//
//  Extensions.swift
//  Gameofchats
//
//  Created by artyom korotkov on 4/6/19.
//  Copyright © 2019 artyom korotkov. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImagesUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            self.image = cachedImage as! UIImage
            return
        }
        
        let url = NSURL(string: urlString)
        
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage , forKey: urlString as AnyObject) as AnyObject
                    self.image = downloadedImage
                }
                
            }
            
        }).resume()
    }
    
}
