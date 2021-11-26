//
//  PusherController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 19/10/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

/*
import UIKit
import PusherSwift

class PusherController: NSObject {
    
    static let sharedInstance = PusherController()

    var driverChannel : PusherChannel?
    var pusher : Pusher?
    
    override init() {
        
        super.init()
        
        

        
        let options = PusherClientOptions(
            host: .cluster(PusherConst.CLUSTER),
            encrypted: true
        )
        
        pusher = Pusher(key: PusherConst.API_KEY, options: options)
        pusher!.connect()
        
        driverChannel = pusher!.subscribe("App.Driver.\(AppManager.sharedInstance.currentUser!.driverID!)")
        
        /*
        print("Driver ID: \(AppManager.sharedInstance.currentUser!.driverID!)")
        print("App.Driver.\(AppManager.sharedInstance.currentUser!.driverID!)")
        print("App\\Events\\JobActivated")
         */
        
        connectChannels()
    }
    
    func connectChannels() {
        
        
        driverChannel!.bind(eventName: "App\\Events\\JobActivated", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let message = data["message"] as? String {
                    print(message)
                }
                else {
                    print("No message")
                }
            }
            else {
                print("No pusher data")
            }
        })
        
        driverChannel!.bind(eventName: "App\\Events\\JobCancelled", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let message = data["message"] as? String {
                    print(message)
                    
                }
                else {
                    print("No message")
                }
            }
            else {
                print("No pusher data")
            }
        })
        
        driverChannel!.bind(eventName: "App\\Events\\ForceLogout", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let eventData = data["force-logout"] as? Bool {
                    
                    DispatchQueue.main.async {
                        let alertViewController = UIAlertController(title: nil, message: "An operator has requested a force-logout", preferredStyle: .alert)
                        
                        alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            
                            
                           LoginManager.forcedLogout()
                            
                            
                        }))
                        
                        let vc = AppManager.sharedInstance.getTopViewController()
                        vc.present(alertViewController, animated: true, completion: nil)
                    }
                }
                else {
                    print("No message")
                }
            }
            else {
                print("No pusher data")
            }
        })
        
        driverChannel!.bind(eventName: "App\\Events\\JobUpdated", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let message = data["job"] as? String {
                    print(message)
                    
                }
                else {
                    print("No message")
                }
            }
            else {
                print("No pusher data")
            }
        })
        
        driverChannel!.bind(eventName: "App\\Events\\JobEdited", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let message = data["job"] as? String {
                    print(message)
                    
                }
                else {
                    print("No message")
                }
            }
            else {
                print("No pusher data")
            }
        })
        
    }
}
 */
