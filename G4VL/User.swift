//
//  User.swift
//  G4VL
//
//  Created by Foamy iMac7 on 06/09/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import PushNotifications
import Bugsnag

let kUserDefault = UserDefaults.standard
let kUserDetail = "UserDetail"

class User: NSObject, NSCoding,Codable {
    
    var driverID : Int!
    var accessToken : String!
    var pushNotificationInterest : String!
    var officeNumber : String!
    var driverName : String!
    
    init(accessToken: String, driverID: Int, pushNotificationInterest : String, officeNumber : String?, driverName : String?) {
        self.accessToken = accessToken
        self.driverID = driverID
        self.pushNotificationInterest = pushNotificationInterest;
        self.officeNumber = officeNumber ?? ""
        self.driverName = driverName ?? ""
        
        
        do {
            try PushNotifications.shared.subscribe(interest: pushNotificationInterest)
        }
        catch {
            let exception = NSException(name:NSExceptionName(rawValue: "Userinit"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print("Subscribe Error: \(error.localizedDescription)")
        }
    }
    
    required init(coder decoder: NSCoder) {
        self.driverID = decoder.decodeInteger(forKey: ApiConstants.Login.ResConst.driverID)
        self.accessToken = (decoder.decodeObject(forKey: ApiConstants.Login.ResConst.accessToken) as! String)
        self.pushNotificationInterest = (decoder.decodeObject(forKey: "pusher_push_interest") as! String)
        self.officeNumber = (decoder.decodeObject(forKey: "call_the_office_telephone_number") as! String)
        self.driverName = (decoder.decodeObject(forKey: "driver_name") as! String)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(driverID!, forKey: ApiConstants.Login.ResConst.driverID)
        coder.encode(accessToken!, forKey: ApiConstants.Login.ResConst.accessToken)
        coder.encode(pushNotificationInterest!, forKey: "pusher_push_interest");
        coder.encode(officeNumber!, forKey: "call_the_office_telephone_number");
        coder.encode(driverName!, forKey: "driver_name");
    }
    
}
extension User{
    
    static var isUserLoggedIn:Bool{
        if let userDetail  = kUserDefault.value(forKey: kUserDetail) as? Data{
            return self.isValiduserDetail(data: userDetail)
        }else{
            return false
        }
    }
    func setuserDetailToUserDefault(){
        do{
            let userDetail = try JSONEncoder().encode(self)
            kUserDefault.setValue(userDetail, forKey:kUserDetail)
            kUserDefault.synchronize()
        }catch{
            let exception = NSException(name:NSExceptionName(rawValue: "setuserDetailToUserDefault"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }
    }
    static func isValiduserDetail(data:Data)->Bool{
        do {
            let _ = try JSONDecoder().decode(User.self, from: data)
            return true
        }catch{
            let exception = NSException(name:NSExceptionName(rawValue: "isValiduserDetail"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            return false
        }
    }
    static func getUserFromUserDefault() -> User?{
        if let userDetail = kUserDefault.value(forKey: kUserDetail) as? Data{
            do {
                let user:User = try JSONDecoder().decode(User.self, from: userDetail)
                return user
            }catch{
                let exception = NSException(name:NSExceptionName(rawValue: "getUserFromUserDefault"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
                return nil
            }
        }
        DispatchQueue.main.async {
            //ShowToast.show(toatMessage: kCommonError)
        }
        return nil
    }
    static func removeUserFromUserDefault(){
        kUserDefault.removeObject(forKey:kUserDetail)
    }
    
}
