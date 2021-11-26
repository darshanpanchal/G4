//
//  AppManager.swift
//  G4VL
//
//  Created by Foamy iMac7 on 11/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import KeychainSwift
import CoreData


class AppManager: NSObject {
    
    static let sharedInstance = AppManager()
    
    let keychain = KeychainSwift()
    var updatedDateFormatter : DateFormatter?
    var inspectionContainer : InspectionContainer?
    
    var allJobs : [Job] = []
    var inactiveJobs : [Job] = []
    var activeJobs : [Job] = []
    var currentJob : Job? {
        didSet {
            if let job = currentJob, let id = job.id {
                LocationSingleton.sharedInstance.start()
                LocationSingleton.sharedInstance.jobID = job.id ?? 0
                UserDefaults.standard.set(id, forKey: Preferences.LAST_OPENED)
            }
            else {
                LocationSingleton.sharedInstance.jobComplete()
            }
        }
    }
    var currentJobAppraisal : JobAppraisal?
    
    var partsToComplete : [String] = []
    var sectionsToComplete : [String] = []
    var completedParts : [String] = []
    var completedSections : [String] = []
    var damagedParts : [String] = []
    
   var progressControl : AssessmentProgressControl?
    
    var homeVC : UIViewController?
    
    let defaults = UserDefaults.standard
    
    var currentUser : User?
    
    
    private override init() {
        super.init()
        
        keychain.synchronizable = true
        
        updatedDateFormatter = DateFormatter()
        updatedDateFormatter?.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        
    }
    
    
    func isModal(vc : UIViewController) -> Bool {
        if vc.presentingViewController != nil {
            return true
        } else if vc.navigationController?.presentingViewController?.presentedViewController == vc.navigationController  {
            return true
        } else if vc.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }


    func getTopViewController() -> UINavigationController {
        
        
        var viewController = UINavigationController()
        
        if let vc = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            viewController = vc
            var presented = vc
            while let top = presented.presentedViewController {
                presented = UINavigationController.init(rootViewController: top)
                viewController = UINavigationController.init(rootViewController: top)
            }
        }
        
        return viewController
        
    }
    
    func sessionExpired() {
        DispatchQueue.main.async {
            let vc = self.getTopViewController()
            let alertViewController = UIAlertController.init(title: "Session Expired", message: "Your session is expired.Please login to continue.", preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: { (_) in
                
                    User.removeUserFromUserDefault()
                    vc.popToRootViewController(animated: false)
                
            })
            alertViewController.addAction(alertAction)
            if User.isUserLoggedIn{
                vc.present(alertViewController, animated: true, completion: nil)
            }
        }
        
        
    }
    
   
    
    
}


extension String {
    func base64()->String {
        return Data(self.utf8).base64EncodedString()
    }
    func decodeBase64()->UIImage {
        return UIImage(data: Data(base64Encoded: self, options: .ignoreUnknownCharacters)!)!
    }
    func getImage()->UIImage? {
        
        
        let imageURL = URL(fileURLWithPath: self)
        return UIImage(contentsOfFile: imageURL.path)
        
    }
    func buildFilePathInDirectory(_ directory:FileManager.SearchPathDirectory) -> String {
        let path = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath:path)
        
        return url.appendingPathComponent(self).path
    }
}

extension UIImage {
    func base64()->String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        //return UIImageJPEGRepresentation(self, Defaults.compression)!.base64EncodedString()
    }
}
extension Data {
    
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


