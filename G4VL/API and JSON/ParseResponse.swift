//
//  ParseResponse.swift
//  G4VL
//
//  Created by Michael Miller on 07/03/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit
import Bugsnag

class ParseResponse: NSObject {

    
    static func parseLoginData(data:Data?, completion:(_ user : User?, _ errorString : String?)->()) {
        
        do {
            let parsedJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            let accessToken = parsedJson[ApiConstants.Login.ResConst.accessToken] as! String
            let driverID = parsedJson[ApiConstants.Login.ResConst.driverID] as! Int
            let pushNotificationInterest = parsedJson["pusher_push_interest"] as! String
            var officeNumber : String?
            if parsedJson["call_the_office_telephone_number"] != nil {
                officeNumber = (parsedJson["call_the_office_telephone_number"] as! String)
            }
            
            var driverName : String?
            if parsedJson["driver_name"] != nil {
                driverName = (parsedJson["driver_name"] as! String)
            }
            
            let user = User(accessToken: accessToken, driverID: driverID, pushNotificationInterest: pushNotificationInterest,  officeNumber : officeNumber, driverName: driverName)
            
            
            completion(user, nil)
        }
        catch {
            let exception = NSException(name:NSExceptionName(rawValue: "ParseResponse"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print("Error: \(error.localizedDescription)")
            completion(nil, "An unknown error ocurred")
        }
    }
    
    
    static func parseJobsData(data:Data?, completion:(_ jobs : [Job]?, _ errorString : String?)->()) {
       
        do {
            let parsedJobs : [Job]?  = try JSONDecoder().decode(Jobs.self, from: data!)
             completion(parsedJobs, nil)
        }
        catch let error {
            let exception = NSException(name:NSExceptionName(rawValue: "parseJobsData"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print("parseJobsData: \(error)")
            completion(nil, nil)
        }
    }
}
