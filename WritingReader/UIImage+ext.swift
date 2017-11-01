//
//  UIImage+ext.swift
//  WritingReader
//
//  Created by Guillermo Colin on 10/12/17.
//  Copyright © 2017 Hezekiah Valdez. All rights reserved.
//

import UIKit

//  Declare imgCache of type NSCache.
let imgCache = NSCache<NSString, AnyObject>()

/*  Helper Extension for the UIIMageView*/
extension UIImageView {
    
    //  Function to load the image.
    func loadIMG(URL_String: String){
        
        //  Check if image exists in cache first. If it does then do NOT trigger a dataTask.
        if let cachedImage = imgCache.object(forKey: URL_String as NSString) as? UIImage{
            print("Thinks it's already cached")
            self.image = cachedImage
            return
        }
        
        //  Else perform a download wit the given URL.
        let url = URL(string: URL_String)
        print("Profile img needed to be fetched")
        
        URLSession.shared.dataTask( with: url!, completionHandler: { (data, response, error) in
            print("getting in URLSession")
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!){
                    
                    imgCache.setObject(downloadedImage, forKey: URL_String as NSString)
                    
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
}
