//
//  PermissionsViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 30/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CoreLocation
import UserNotifications

class PermissionsViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var swCamera : SegmentSwitch!
    @IBOutlet var swPhotoLibrary : SegmentSwitch!
    @IBOutlet var swMicrophone : SegmentSwitch!
    @IBOutlet var swLocation : SegmentSwitch!
    @IBOutlet var swPushNotifications : SegmentSwitch!
    var locationManager = CLLocationManager()
    var loaded = false;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        updateUI()
    
        
        
        loaded = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: NSNotification.Name(Notification.REFRESH_PERMISSIONS), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if locationManager.delegate == nil {
            locationManager.delegate = self;
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func getCameraAccess() {
        self.view.isUserInteractionEnabled = false
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
            granted in
            DispatchQueue.main.async {
                self.updateUI()
                if !granted {
                    self.presentSettingsAlert(permission: "the devices camera")
                }
                
            }
        })
    
    }
    
    @IBAction func getLibraryAccess() {
        
        self.view.isUserInteractionEnabled = false
        PHPhotoLibrary.requestAuthorization({
            status in
            
            DispatchQueue.main.async {
                self.updateUI()
                if status != PHAuthorizationStatus.authorized {
                    self.presentSettingsAlert(permission: "the devices photo library")
                }
            }
        })
        
    }
    
    @IBAction func getMicrophoneAccess() {
        
        self.view.isUserInteractionEnabled = false
        AVAudioSession.sharedInstance().requestRecordPermission({
            granted in
            DispatchQueue.main.async {
                self.updateUI()
                if !granted {
                    self.presentSettingsAlert(permission: "the devices microphone")
                }
                
            }
        })
        
    }
    
    
    @IBAction func getFullLocationAccess() {
        
        self.view.isUserInteractionEnabled = false
        
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .authorizedWhenInUse  {
            self.presentSettingsAlert(permission: "receive your location even when the app is closed")
            self.updateUI()
        }
        else {
            locationManager.requestAlwaysAuthorization()
        }
    }

    
    
    @IBAction func getPushNotificationAccess() {
        
        self.view.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                DispatchQueue.main.async {
                    self.updateUI()
                    /*
                    if !granted {
                        self.presentSettingsAlert(permission: "send you push notifications")
                    }
                    else {
                        self.updateUI()
                    }*/
                    
                }
            }
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        switch status {
        case .authorizedAlways:
            updateUI()
            break
        default:
            self.presentSettingsAlert(permission: "receive your location even when the app is closed")
            self.updateUI()
            break
        }
    }
    
    
    
    func presentSettingsAlert(permission:String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Permission Denied", message: "You have denied the app permission to \(permission).\n\nTo resolve this issue you have to go to you apps settings and allow the permission manually.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                action in
                self.updateUI()
                alert.dismiss(animated: false, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: {
                action in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        
                    })
                }

                
                alert.dismiss(animated: false, completion: nil)
            }))
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @objc func updateUI() {
        
        
        var allGranted = true;
        
        
        //Camera Access
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            swCamera.isOn = true
            swCamera.isUserInteractionEnabled = false
        }
        else {
            swCamera.isUserInteractionEnabled = true
            swCamera.isOn = false
            allGranted = false
        }
        
        //Library Access
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            swPhotoLibrary.isOn = true
            swPhotoLibrary.isUserInteractionEnabled = false
        }
        else {
            swPhotoLibrary.isUserInteractionEnabled = true
            swPhotoLibrary.isOn = false
            allGranted = false
        }
        
        
        
        //Microphone Access
        if AVAudioSession.sharedInstance().recordPermission == .granted {
            swMicrophone.isOn = true
            swMicrophone.isUserInteractionEnabled = false
        }
        else {
            swMicrophone.isUserInteractionEnabled = true
            swMicrophone.isOn = false
            allGranted = false
        }
       
        
        //Location
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .authorizedAlways {
                swLocation.isOn = true
                swLocation.isUserInteractionEnabled = false
            }
            else {
                swLocation.isUserInteractionEnabled = true
                swLocation.isOn = false
                allGranted = false
            }
        }
        else {
            swLocation.isUserInteractionEnabled = true
            swLocation.isOn = false
            allGranted = false
        }
        
        
        //Remote Notifications
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings: UNNotificationSettings) in
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
                
                if settings.authorizationStatus == .authorized {
                    self.swPushNotifications.isOn = true
                    self.swPushNotifications.isUserInteractionEnabled = false
                }
                else {
                    self.swPushNotifications.isUserInteractionEnabled = true
                    self.swPushNotifications.isOn = false
//                    allGranted = false
                }
                if allGranted {
                    //
                    NotificationCenter.default.removeObserver(self)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }

}
