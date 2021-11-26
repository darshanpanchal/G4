//
//  AppDelegate.swift
//  G4VL
//
//  Created by Foamy iMac7 on 10/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import PushNotifications
import Fabric
import Crashlytics
import Firebase
import UserNotifications
import Uploadcare
import Bugsnag

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let pushNotifications = PushNotifications.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let _ = UCClient.default(){
            UCClient.default()!.setPublicKey("bee70de1d73512122537")
        }
        
        IQKeyboardManager.shared.enable = true
        
        self.pushNotifications.start(instanceId:"173f8bcf-9219-4ac7-abce-39c38b8c0323")//"13ee132c-03bc-4835-b1d0-396dfbd0f83e") 
        self.pushNotifications.registerForRemoteNotifications()
        
//        FirebaseApp.configure()
//        Fabric.with([Crashlytics.self])
        
        UNUserNotificationCenter.current().delegate = self
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings: UNNotificationSettings) in
            
        })
        //start bugsnag with api key
        self.configureBugsnag()
       
        return true
    }
   
    func openAppUpdateAlert(){
        guard User.isUserLoggedIn else {
            return
        }
        let currentUser = User.getUserFromUserDefault()
        
        if let objURL = URL.init(string: ApiConstants.GETAppVersion.endPoint){
            let objRequest = Requests.basicRequest(url: objURL, method: "GET", body: nil, accessToken: currentUser!.accessToken)
            Response.shared.basicNew(urlRequest: objRequest) { (apiResult) in
                if let code = apiResult.statusCode,code == 200,let objData = apiResult.data{
                    do{
                        if let objJSON = try JSONSerialization.jsonObject(with: objData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]{
                            if let appVersion = objJSON["IosAppCode"] as? Int{
                                if let currentBuid = Int(Bundle.main.buildNumber),currentBuid < appVersion{
                                    DispatchQueue.main.async {
                                        let updateAlert = UIAlertController.init(title: "Your App is Out of Date", message: "\nDownload the latest version of G4 Driver to try new features and get a better experience.", preferredStyle: .alert)
                                        let alertAction = UIAlertAction.init(title: "Update", style: .default, handler: { (_ ) in
                                            let appStoreURL = "https://apps.apple.com/us/app/g4-driver/id1466762007#?platform=iphone"
                                            if let objURL = URL.init(string: appStoreURL){
                                                UIApplication.shared.open(objURL, options: [:]) { (finished) in
                                                    
                                                }
                                            }
                                        })
                                        updateAlert.addAction(alertAction)
                                        self.window?.rootViewController?.present(updateAlert, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }catch{
                        
                    }
                    
                }

            }
        }
    }
    func configureBugsnag(){
        let config = BugsnagConfiguration()
        config.apiKey = "126e325bc52657adde10b42ac7472e77"
        // ... customize other config properties as needed
        config.notifyReleaseStages = ["staging","production","development"]
        config.releaseStage = ApiConstants.staging ? "development":"production"
        config.appVersion = "\(Bundle.main.versionNumber) (\(Bundle.main.buildNumber)"
        if User.isUserLoggedIn{
            if let currentUser = User.getUserFromUserDefault(){
                let userID = "\(currentUser.driverID ?? 0)"
                let userName = "\(currentUser.driverName ?? "")"
                var userEmail = ""
                if AppManager.sharedInstance.keychain.get(Preferences.USERNAME) != nil {
                    userEmail = AppManager.sharedInstance.keychain.get(Preferences.USERNAME) ?? ""
                }
                config.setUser(userID, withName:userName, andEmail:userEmail)
            }
        }
        Bugsnag.start(with: config)
        
        let _ = NSException(name:NSExceptionName(rawValue: "Test123"),
                                    reason:"Test123",
            userInfo:nil)
        //let e = NSException.init(name: NSExceptionName.init("Test"), reason: "Test", userInfo:nil)
//        Bugsnag.notify(exception)
       
    }
  
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if let _ = AppManager.sharedInstance.currentUser {
            if !UploadManager.shared.inUploadCycle {
                UploadManager.shared.checkForWaitingUploads()
            }
            NotificationCenter.default.post(name: NSNotification.Name(Notification.REFRESH_JOBS), object: nil)
        }
         completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return UCClient.default()?.handle(url) ?? true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushNotifications.registerDeviceToken(deviceToken) {
            
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let _ = AppManager.sharedInstance.currentUser {
            if !UploadManager.shared.inUploadCycle {
                UploadManager.shared.checkForWaitingUploads()
            }
            NotificationCenter.default.post(name: NSNotification.Name(Notification.REFRESH_JOBS), object: nil)
        }
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        self.perform(#selector(self.delayedPermissionCheck), with: nil, afterDelay: 2.0)

        self.openAppUpdateAlert()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }

    @objc func delayedPermissionCheck() {
        PermissionCheck.checkPermissions()
    }
    
    
}

