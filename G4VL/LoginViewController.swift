//
//  LoginViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 25/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import LocalAuthentication
import Crashlytics

class LoginViewController: UIViewController {
    
    var appManager = AppManager.sharedInstance
    
    var context = LAContext()
    
    @IBOutlet var txtUser : UITextField!
    @IBOutlet var txtPass : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        txtPass.layer.borderColor = UIColor.white.cgColor
        txtUser.layer.borderColor = UIColor.white.cgColor
        txtPass.layer.borderWidth = 3.0
        txtUser.layer.borderWidth = 3.0
        
        if appManager.keychain.get(Preferences.USERNAME) != nil {
            txtUser.text = appManager.keychain.get(Preferences.USERNAME)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeDetails), name: NSNotification.Name(Notification.LOG_OUT), object: nil)
        
        
        
        
        if User.isUserLoggedIn{
            AppManager.sharedInstance.currentUser = User.getUserFromUserDefault()!
            self.moveToDash()
        }else{
            print(appManager.currentUser ?? "")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func removeDetails() {
        context = LAContext()
        self.txtPass.text = ""
        self.txtUser.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if DEBUG
//        txtUser.text = "tracy@blink.uk"//digital.co.uk"//"android@g4.app" //"ios@g4.app"//
//        txtPass.text = "Tracy123!"//"p"//"12345"//"p"//
        #endif
        var error: NSError?
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {//check if user has been asked to enable TouchID
        
            if appManager.defaults.bool(forKey: Preferences.TOUCH_ID_ENABLED) {
                //TouchID enabled
                authenticateUser()
            }
            
        }
        
    }

    @IBAction func driperSupportCall(sender:UIButton){
        let pickUpNumber = "+4401782939079"
        if let pickUpURL = URL(string: "tel://\(pickUpNumber)"),pickUpNumber.count > 0{
            UIApplication.shared.open(pickUpURL, options: [:]) { (finished) in
            }
        }
    }
    @IBAction func login() {
        //Crashlytics.sharedInstance().crash()
        if txtUser.text!.trimmingCharacters(in: .whitespaces).count < 4 {
            self.present(SimpleAlert.dismissAlert(message: "Please enter a valid username", title: nil, cancel: "OK"), animated: true, completion: nil)
            return
        }
        
        if txtPass.text!.trimmingCharacters(in: .whitespaces).count == 0 {
            
            self.present(SimpleAlert.dismissAlert(message: "Please enter a valid password", title: nil, cancel: "OK"), animated: true, completion: nil)
            return;
        }
        
        self.view.isUserInteractionEnabled = false
        self.view.makeToastActivity(.center)
        
        Requests.loginUser(email: txtUser.text!, password: txtPass.text!) { (apiResult) in
            
            DispatchQueue.main.async {
            
                self.view.isUserInteractionEnabled = true
                self.view.hideToastActivity()
                
            
                if apiResult.userMessage != nil {
                    self.present(SimpleAlert.dismissAlert(message: apiResult.userMessage!.rawValue, title: "", cancel: "OK"), animated: true, completion: nil)
                    return
                }
                else if apiResult.statusCode != nil {
                    if apiResult.statusCode! == 401 {
                        self.present(SimpleAlert.dismissAlert(message: "Incorrect Login Details", title: "", cancel: "OK"), animated: true, completion: nil)
                        return
                    }
                    else if apiResult.statusCode! != 200 {
                        self.present(SimpleAlert.dismissAlert(message:ErrorHelper.CustomErrorType.unknown.rawValue , title: "", cancel: "OK"), animated: true, completion: nil)
                        return
                    }
                }
               
                
                ParseResponse.parseLoginData(data: apiResult.data, completion: { (user, errorMessage) in
                    DispatchQueue.main.async {
                        if user != nil {
                            if !self.appManager.defaults.bool(forKey: Preferences.TOUCH_ID_REQUESTED) {
                                self.appManager.keychain.set(self.txtUser.text!, forKey: Preferences.USERNAME)
                                self.appManager.keychain.set(self.txtPass.text!, forKey: Preferences.PASSWORD)
                            }
                            else if self.appManager.defaults.bool(forKey: Preferences.TOUCH_ID_REQUESTED) && self.appManager.defaults.bool(forKey: Preferences.TOUCH_ID_ENABLED) {
                                
                                //Update keychain if login is successful and biometrics are enabled and username/password differ from previously saved
                                
                                if self.appManager.keychain.get(Preferences.USERNAME) != self.txtUser.text! {
                                    self.appManager.keychain.set(self.txtUser.text!, forKey: Preferences.USERNAME)
                                }
                                if self.appManager.keychain.get(Preferences.PASSWORD) != self.txtPass.text! {
                                    self.appManager.keychain.set(self.txtPass.text!, forKey: Preferences.PASSWORD)
                                }
                                
                            }
                            
                            AppManager.sharedInstance.currentUser = user
                            user?.setuserDetailToUserDefault()
                            if !OfflineFolderStructure.doesFolderExist(path: OfflineFolderStructure.getDriverPath(id: AppManager.sharedInstance.currentUser!.driverID!)) {
                                //create a local directory for the driver
                                OfflineFolderStructure.createFolder(named: OfflineFolderStructure.getDriverPath(id: AppManager.sharedInstance.currentUser!.driverID!))
                            }
                            self.apiRequestForUpdateCheck(accessToken:user!.accessToken)

                            
                            self.moveToDash()
                        }
                        else {
                            self.present(SimpleAlert.dismissAlert(message: apiResult.errorMessage, title: "", cancel: "OK"), animated: true, completion: nil)
                        }
                        
                    }
                })
                
            }
        }
        
        
    }
    func apiRequestForUpdateCheck(accessToken:String){
        let body =  "device_platform=iOS" + "environment=\(ApiConstants.staging ? "development":"production")" + "device_driver_app_current_version=\(Bundle.main.versionNumber)"
        print(body)
        if let objURL = URL.init(string: ApiConstants.UpdateCheck.endPoint){
            let objRequest = Requests.basicRequest(url: objURL, method: "POST", body: body, accessToken: accessToken)
            Response.shared.basicNew(urlRequest: objRequest) { (apiResult) in
                print("\(apiResult.statusCode)")
            }
        }
        
    }

    
    func moveToDash() {
        
        self.performSegue(withIdentifier: "to_dash", sender: nil)
        
    }
    
    
    func authenticateUser() {
        
        // Set the reason string that will appear on the authentication alert.
        
        
        let idType = Biometrics.checkForBiometry(context: context)
        if idType == .kNone {
            return
        }
        let reasonString = idType == .kFace ? "Login with Face ID" : "Login with Touch ID"
        
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: {
            success, error in
            
            DispatchQueue.main.async {
                
                if success {
                    self.txtPass.text = self.appManager.keychain.get(Preferences.PASSWORD) 
                    self.txtUser.text = self.appManager.keychain.get(Preferences.USERNAME) 
                    self.login()
                    
                }
                
                if error != nil {
                    print(error!.localizedDescription)
                }
                
            }
            
        })
        
    }
    
    
    
   
    
    
}
