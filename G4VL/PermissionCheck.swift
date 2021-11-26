//
//  PermissionCheck.swift
//  G4VL
//
//  Created by Foamy iMac7 on 19/10/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications
import Photos

class PermissionCheck: NSObject {
    
    static func checkPermissions() {
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) !=  AVAuthorizationStatus.authorized {
            self.perform(#selector(showPermissionView), with: nil, afterDelay: 0.3)
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            self.perform(#selector(showPermissionView), with: nil, afterDelay: 0.3)
            return
        }
        
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() != .authorizedAlways {
                self.perform(#selector(showPermissionView), with: nil, afterDelay: 0.3)
                return
            }
        }
        else {
            self.perform(#selector(showPermissionView), with: nil, afterDelay: 0.3)
        }
        
        if AVAudioSession.sharedInstance().recordPermission != .granted {
            self.perform(#selector(showPermissionView), with: nil, afterDelay: 0.3)
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings: UNNotificationSettings) in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
//                    self.perform(#selector(self.showPermissionView), with: nil, afterDelay: 0.3)
                    return
                }
            }
        })
    }
    
    @objc static func showPermissionView() {
        DispatchQueue.main.async {
            let vc = AppManager.sharedInstance.getTopViewController()
            
            if vc is PermissionsViewController {
                NotificationCenter.default.post(name: NSNotification.Name(Notification.REFRESH_PERMISSIONS), object: nil, userInfo: nil)
                return
            }
            
            if vc is UIAlertController {
                let presenting = vc.presentingViewController!
                
                if presenting is PermissionsViewController {
                    NotificationCenter.default.post(name: NSNotification.Name(Notification.REFRESH_PERMISSIONS), object: nil, userInfo: nil)
                    return
                }
                
                vc.dismiss(animated: false, completion: {
                    
                    let sb = UIStoryboard(name: "GloballyUsed", bundle: nil)
                    let permVC = sb.instantiateViewController(withIdentifier: "permissions") as! PermissionsViewController
                    presenting.present(permVC, animated: true, completion: nil)
                    
                })
                
            }
            else {
                let sb = UIStoryboard(name: "GloballyUsed", bundle: nil)
                let permVC = sb.instantiateViewController(withIdentifier: "permissions") as! PermissionsViewController
                vc.present(permVC, animated: true, completion: nil)
            }
            
            
        }
        
    }
}
