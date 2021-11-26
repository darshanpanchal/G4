//
//  VheicleDetailsManager.swift
//  G4VL
//
//  Created by Foamy iMac7 on 25/10/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import Bugsnag

class VehicleDetailsManager: NSObject {

    
    //MARK: Get Vehicle Data
    
    static func getVehicleDetails() {
        
        
        if let path = Bundle.main.path(forResource: "vehicle_details", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
                self.parseVehicleDetails(data: data)
                
            } catch {
                // handle error
                let exception = NSException(name:NSExceptionName(rawValue: "getVehicleDetails"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
            }
        }
        
    }
    
    static func parseVehicleDetails(data:Data) {
       
        do {
            let sections = try JSONDecoder().decode([VehicleDetailSection].self, from: data)
            
            if AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal == nil {
                AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal = ManualAppraisal(pickupvalue: nil, dropoffvalue: nil)
            }
            
            
            if AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal!.pickup.vehicleDetailSections == nil {
                AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal!.pickup.vehicleDetailSections = sections
                
                JobsManager.saveJobAppraisal(job: AppManager.sharedInstance.currentJobAppraisal!, saveExpenses: false)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(Notification.REFRESH_VEHICAL_DETAILS), object: nil)
                }
            }
               
        }
        catch let error {
            print("parseVehicleDetails: \(error)")
            let exception = NSException(name:NSExceptionName(rawValue: "parseVehicleDetails"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }
            
       
    }
    
    
    static func getVehicleParts(vehicleType : String) {
        
        do {
            
            if let path = Bundle.main.path(forResource: "parts_\(vehicleType.lowercased())", ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let parts = try JSONDecoder().decode([VehiclePart].self, from: data)
                
                
                if AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal == nil {
                    AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal = ManualAppraisal(pickupvalue: nil, dropoffvalue: nil)
                }
                
                if AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal!.pickup.vehicleParts == nil {
                    AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal!.pickup.vehicleParts = parts
                    
                    JobsManager.saveJobAppraisal(job: AppManager.sharedInstance.currentJobAppraisal!, saveExpenses: false)
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(Notification.REFRESH_VEHICAL_PARTS), object: nil)
                    }
                }
            }
            
            
        }
        catch let error {
            print("parseVehicleDetails: \(error)")
            let exception = NSException(name:NSExceptionName(rawValue: "getVehicleParts"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }
        
        
    }

    
}
