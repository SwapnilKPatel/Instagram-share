//
//  ShareImageInstagram.swift
//  DemoProject(ChoosePicture)
//
//  Created by Swapnil Patel on 25/06/19.
//  Copyright © 2019 Swapnil Patel. All rights reserved.
//

import Foundation
import UIKit
import Photos

public protocol ShareStoriesDelegate {
    func error(message: String)
    func success()
}

open class ShareImageInstagram {
    
    private let instagramURL = URL(string: "instagram://app")
    private let instagramStoriesURL = URL(string: "instagram-stories://share")
    
    var delegate: ShareStoriesDelegate?
    
    public init() {
        
    }
    func alert (with message :String,title :String = "" , appStoreurl : String , parentVC : UIViewController) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            if let url = URL(string: appStoreurl),
                UIApplication.shared.canOpenURL(url)
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        let CancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
            print("You've pressed Cancel Button")
        }
        alertController.addAction(OKAction)
        alertController.addAction(CancelAction)
        parentVC.present(alertController, animated: true, completion: nil)
    }
    
    public func postToInstagramFeed(image: UIImage, caption: String, bounds: CGRect, view: UIView) {
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { success, error in
            if success {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                if let lastAsset = fetchResult.firstObject {
                    let localIdentifier = lastAsset.localIdentifier
                    let urlFeed = "instagram://library?LocalIdentifier=" + localIdentifier
                    guard let url = URL(string: urlFeed) else {
                        self.delegate?.error(message: "Could not open url")
                        return
                    }
                    DispatchQueue.main.async {
                        if UIApplication.shared.canOpenURL(url) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                    self.delegate?.success()
                                })
                            } else {
                                UIApplication.shared.openURL(url)
                                self.delegate?.success()
                                
                            }
                        } else {
                            self.delegate?.error(message: "Instagram not found")
                        }
                    }
                }
            } else if let error = error {
                self.delegate?.error(message: error.localizedDescription)
            }
            else {
                self.delegate?.error(message: "Could not save the photo")
            }
        })
    }
    
    public func postToInstagramStories(data: NSData, image: UIImage, backgroundTopColorHex: String, backgroundBottomColorHex: String, deepLink: String) {
        
        DispatchQueue.main.async {
            
            guard let url = self.instagramURL else {
                self.delegate?.error(message: "URL not valid")
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                
                guard let urlScheme = self.instagramStoriesURL else {
                    self.delegate?.error(message: "URL not valid")
                    return
                }
                
                let pasteboardItems = ["com.instagram.sharedSticker.stickerImage": image,
                                       "com.instagram.sharedSticker.backgroundTopColor" : backgroundTopColorHex,
                                       "com.instagram.sharedSticker.backgroundBottomColor" : backgroundBottomColorHex,
                                       "com.instagram.sharedSticker.backgroundVideo": data,
                                       "com.instagram.sharedSticker.contentURL": deepLink] as [String : Any]
                
                if #available(iOS 10.0, *) {
                    let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate : NSDate().addingTimeInterval(60 * 5)]
                    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                    
                } else {
                    UIPasteboard.general.items = [pasteboardItems]
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlScheme, options: [:], completionHandler: { (success) in
                        self.delegate?.success()
                    })
                } else {
                    UIApplication.shared.openURL(urlScheme)
                    self.delegate?.success()
                }
                
            } else {
                self.delegate?.error(message: "Could not open instagram URL. Check if you have instagram installed and you configured your LSApplicationQueriesSchemes to enable instagram's url")
            }
        }
    }
    
    public func postToInstagramStories(image: UIImage, backgroundTopColorHex: String, backgroundBottomColorHex: String, deepLink: String) {
        
        DispatchQueue.main.async {
            
            guard let url = self.instagramURL else {
                self.delegate?.error(message: "URL not valid")
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                
                guard let urlScheme = self.instagramStoriesURL else {
                    self.delegate?.error(message: "URL not valid")
                    return
                }
                
                let pasteboardItems = ["com.instagram.sharedSticker.stickerImage": image,
                                       "com.instagram.sharedSticker.backgroundTopColor" : backgroundTopColorHex,
                                       "com.instagram.sharedSticker.backgroundBottomColor" : backgroundBottomColorHex,
                                       "com.instagram.sharedSticker.contentURL": deepLink] as [String : Any]
                
                if #available(iOS 10.0, *) {
                    let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate : NSDate().addingTimeInterval(60 * 5)]
                    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                    
                } else {
                    UIPasteboard.general.items = [pasteboardItems]
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlScheme, options: [:], completionHandler: { (success) in
                        self.delegate?.success()
                    })
                } else {
                    UIApplication.shared.openURL(urlScheme)
                    self.delegate?.success()
                }
                
            } else {
                self.delegate?.error(message: "Could not open instagram URL. Check if you have instagram installed and you configured your LSApplicationQueriesSchemes to enable instagram's url")
            
            }
        }
    }
    
}
