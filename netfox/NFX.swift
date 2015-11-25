//
//  NFX.swift
//  netfox
//
//  Copyright © 2015 kasketis. All rights reserved.
//

import Foundation
import UIKit

let nfxVersion = "0.1.6"

@objc
public class NFX: NSObject
{
    
    // swiftSharedInstance is not accessible from ObjC
    class var swiftSharedInstance: NFX
    {
        struct Singleton
        {
            static let instance = NFX()
        }
        return Singleton.instance
    }
    
    // the sharedInstance class method can be reached from ObjC
    public class func sharedInstance() -> NFX
    {
        return NFX.swiftSharedInstance
    }
    
    @objc public enum ENFXGesture: Int
    {
        case shake
        case custom
        
        func name() -> String {
            switch self {
            case .shake: return "shake"
            case .custom: return "custom"
            }
        }
    }
    
    var started: Bool = false
    var presented: Bool = false
    var selectedGesture: ENFXGesture = .shake
    var ignoredURLs = [String]()
    
    @objc public func start()
    {
        self.started = true
        NSURLProtocol.registerClass(NFXProtocol)
        print("netfox \(nfxVersion) - [https://github.com/kasketis/netfox]: Started!")
        clearOldData()
    }
    
    func motionDetected()
    {
        if self.started {
            if self.presented {
                hideNFX()
            } else {
                showNFX()
            }
        }
    }
    
    @objc public func setGesture(gesture: ENFXGesture)
    {
        self.selectedGesture = gesture
    }
    
    @objc public func show()
    {
        if (self.started) && (self.selectedGesture == .custom) {
            showNFX()
        } else {
            print("netfox \(nfxVersion) - [ERROR]: Please call start() and setGesture(.custom) first")
        }
    }
    
    @objc public func hide()
    {
        if (self.started) && (self.selectedGesture == .custom) {
            hideNFX()
        } else {
            print("netfox \(nfxVersion) - [ERROR]: Please call start() and setGesture(.custom) first")
        }
    }
    
    @objc public func ignoreURL(url: String)
    {
        self.ignoredURLs.append(url)
    }
    
    private func showNFX()
    {
        if self.presented {
            return
        }
        
        var navigationController: UINavigationController?

        var listController: NFXListController
        listController = NFXListController()
        
        navigationController = UINavigationController(rootViewController: listController)
        navigationController!.navigationBar.translucent = false
        navigationController!.navigationBar.tintColor = UIColor.init(netHex: 0xec5e28)
        navigationController!.navigationBar.barTintColor = UIColor.init(netHex: 0xccc5b9)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.init(netHex: 0xec5e28)]
        
        presentingViewController?.presentViewController(navigationController!, animated: true, completion: { () -> Void in
            self.presented = true
        })


    }
    
    private var presentingViewController: UIViewController? {
        let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        return rootViewController?.presentedViewController ?? rootViewController
    }
    
    private func hideNFX()
    {
        if !self.presented {
            return
        }
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.presented = false
        })
    }
    
    private func clearOldData()
    {
        do {
            let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
            let filePathsArray = try NSFileManager.defaultManager().subpathsOfDirectoryAtPath(documentsPath)
            for filePath in filePathsArray {
                if filePath.hasPrefix("nfx") {
                    try NSFileManager.defaultManager().removeItemAtPath((documentsPath as NSString).stringByAppendingPathComponent(filePath))
                }
            }
            
        } catch {}
    }
    
}
