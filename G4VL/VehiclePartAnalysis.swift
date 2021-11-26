//
//  VehiclePartAnalysis.swift
//  G4VL
//
//  Created by Foamy iMac7 on 26/10/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class VehiclePartAnalysis: NSObject {

    //MARK: Analyse Data
    
    static func removeDamageForVehiclePart(vehiclePart : VehiclePart) {
        
        let damages = vehiclePart.damages!
        for damage in damages {
            if damage.state != nil && damage.state! {
                damage.state = false
            }
            if damage.selected != nil {
                if damage.selected! > 0 {
                    damage.selected = 0
                    
                }
            }
            if damage.text != nil && damage.text!.trimmingCharacters(in: .whitespaces).count > 0 {
                damage.text = ""
            }
            
        }
    }
    
    static func anyDamagesForPart(vehiclePart : VehiclePart)->Bool {
        
        let damages = vehiclePart.damages!
        
        for damage in damages {
            if damage.state != nil && damage.state! {
                return true
            }
            if damage.selected != nil {
                if damage.selected! > 0 {
                    return true
                    
                }
            }
            if damage.text != nil && damage.text!.trimmingCharacters(in: .whitespaces).count > 0 {
                return true
            }
        }
        
        return false
        
    }
    
    static func anyDamageForAssociatedPart(associatedPart : String, pickup:Bool)->Bool {
        
        if AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal == nil {
            return false
        }
        
        if pickup {
            if AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal!.pickup.vehicleParts == nil {
                return false
            }
            
            let vehicleParts = AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal!.pickup.vehicleParts!
            
            for part in vehicleParts {
                if part.name == associatedPart {
                    return anyDamagesForPart(vehiclePart: part)
                }
            }
            return false
        }
        else {
            if AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal!.dropoff.vehicleParts == nil {
                return false
            }
            
            let vehicleParts = AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal!.dropoff.vehicleParts!
            
            for part in vehicleParts {
                if part.name == associatedPart {
                    return anyDamagesForPart(vehiclePart: part)
                }
            }
            return false
        }
        
        
       
    }
 
    
    static func markAssociatedPartAsChecked(associatedPart:String, noDamage:Bool, pickup:Bool) {
    
        let appManager = AppManager.sharedInstance
        
        
        appManager.completedParts.appendWithoutDuplication(associatedPart)
        
        //check if associated part is in damages and remove
        let index = appManager.damagedParts.index(of: associatedPart)
        
        if index != nil {
            appManager.damagedParts.remove(at: index!)
        }
        
        //Edit one occurrence of the associated parts and mark as checked
        
        var result : [VehiclePart]? = nil
        
        if pickup {
            result = appManager.currentJobAppraisal!.manualAppraisal!.pickup.vehicleParts!.filter{
                return $0.name!.trimmingCharacters(in: .whitespaces) == associatedPart.trimmingCharacters(in: .whitespaces)
            }
        }
        else {
            result = appManager.currentJobAppraisal!.manualAppraisal!.dropoff.vehicleParts!.filter{
                return $0.name!.trimmingCharacters(in: .whitespaces) == associatedPart.trimmingCharacters(in: .whitespaces)
            }
        }
        

        
        if result != nil && result!.count > 0 {
            
            let vehiclePart = result!.first!
            
            
            vehiclePart.checked = true
            
            if noDamage {
               vehiclePart.removeDamage()
            }
            
            JobsManager.saveJobAppraisal(job: appManager.currentJobAppraisal!, saveExpenses: false)
            appManager.inspectionContainer!.updateView()
        }
        
        
    }
    
    static func loadAppraisalProgress(pickup:Bool) {
        //looks at the parts
        let appManager = AppManager.sharedInstance
        
        DispatchQueue.global().async {
            
            
            appManager.completedParts = []
            appManager.completedSections = []
            appManager.sectionsToComplete = []
            appManager.damagedParts = []
            appManager.partsToComplete = []
            
            
            let jobAppraisal = AppManager.sharedInstance.currentJobAppraisal!
            
            var parts : [VehiclePart]? = nil
            
            if jobAppraisal.manualAppraisal != nil {
            
                if pickup {
                   parts = jobAppraisal.manualAppraisal!.pickup.vehicleParts
                }
                else {
                    parts = jobAppraisal.manualAppraisal!.dropoff.vehicleParts
                }
                
                if parts != nil {
                    for part in parts! {
                        
                        if anyDamageForAssociatedPart(associatedPart: part.name!,pickup: pickup) {
                            appManager.damagedParts.appendWithoutDuplication(part.name!)
                            appManager.completedParts.appendWithoutDuplication(part.name!)
                            
                        }
                        else {
                            if part.checked != nil && part.checked {
                                appManager.completedParts.appendWithoutDuplication(part.name!)
                            }
                            else {
                                appManager.partsToComplete.appendWithoutDuplication(part.name!)
                            }
                        }
                    }
                }
                
            }
            
            loadSections(pickup: pickup)
        }
    }
    
    static func loadSections(pickup:Bool) {
        //this adds the madatory sections to progress,
        let appManager = AppManager.sharedInstance
        
        let jobAppraisal = AppManager.sharedInstance.currentJobAppraisal!
        
        var sections : [VehicleDetailSection]? = nil
        
        var entry:ManualAppraisalEntry?
        if jobAppraisal.manualAppraisal != nil {
            
            if pickup {
                sections = jobAppraisal.manualAppraisal!.pickup.vehicleDetailSections
            }
            else {
                sections = jobAppraisal.manualAppraisal!.dropoff.vehicleDetailSections
            }
            if pickup{
                entry = jobAppraisal.manualAppraisal!.pickup
            }else{
                entry = jobAppraisal.manualAppraisal!.dropoff
            }
            let images = ["Front","Driver Side","Rear","Passenger Side"]
            for image in images{
                var title = image.replacingOccurrences(of: " ", with: "_").lowercased()
                title.append(" image")
                appManager.sectionsToComplete.appendWithoutDuplication(title)

            }
         
            
            if let sect = entry?.front{
                 var title = sect.label
                 title = title.replacingOccurrences(of: " ", with: "_").lowercased()
                if let uploadcare = sect.uploadCarePhotoNames, uploadcare.count > 0{
                    appManager.completedSections.appendWithoutDuplication(title)
                }else{
                    if appManager.completedSections.contains(title){
                        appManager.completedSections.remove(title)
                    }
                }
            }
            if let sect = entry?.driverside{
                 var title = sect.label
                 title = title.replacingOccurrences(of: " ", with: "_").lowercased()
                if let uploadcare = sect.uploadCarePhotoNames, uploadcare.count > 0{
                    appManager.completedSections.appendWithoutDuplication(title)
                }else{
                    if appManager.completedSections.contains(title){
                        appManager.completedSections.remove(title)
                    }
                }
            }
            if let sect = entry?.rear{
                 var title = sect.label
                 title = title.replacingOccurrences(of: " ", with: "_").lowercased()
                if let uploadcare = sect.uploadCarePhotoNames, uploadcare.count > 0{
                    appManager.completedSections.appendWithoutDuplication(title)
                }else{
                    if appManager.completedSections.contains(title){
                        appManager.completedSections.remove(title)
                    }
                }
            }
            if let sect = entry?.passengerside{
                 var title = sect.label
                 title = title.replacingOccurrences(of: " ", with: "_").lowercased()
                if let uploadcare = sect.uploadCarePhotoNames, uploadcare.count > 0{
                    appManager.completedSections.appendWithoutDuplication(title)
                }else{
                    if appManager.completedSections.contains(title){
                        appManager.completedSections.remove(title)
                    }
                }
            }
            
            
            if sections != nil {
                for sect in sections! {
                    
                    for row in sect.vehicleDetailRows! {
                        
                        if row.identifier == .slider {
                            
                            if row.key == "number_of_keys" {
                                
                                var title = (row.label!)
                                
                                if title.count == 0 {
                                    title = sect.label!
                                }
                                
                                title = title.replacingOccurrences(of: " ", with: "_").lowercased()
                                
                                appManager.sectionsToComplete.appendWithoutDuplication(title)
                                
                                if Int(row.value!) == 0 {
                                    appManager.completedSections.remove(title)
                                }
                                else {
                                    appManager.completedSections.appendWithoutDuplication(title)
                                }
                            }
                            
                        }
                        
                        else if row.identifier == .radio {
                            
                            var title = (row.label!)
                            
                            if title.count == 0 {
                                title = sect.label!
                            }
                            
                            title = title.replacingOccurrences(of: " ", with: "_").lowercased()
                            
                            appManager.sectionsToComplete.appendWithoutDuplication(title)
                            
                            if Int(row.selected!) == 0 {
                                appManager.completedSections.remove(title)
                            }
                            else {
                                appManager.completedSections.appendWithoutDuplication(title)
                            }
                            
                        }
                        
                    }
                }
            }
            
            
        }
        
        
    }
    
    
}
