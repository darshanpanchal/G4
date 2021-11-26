//
//  ApiConstants.swift
//  G4VL
//
//  Created by Michael Miller on 07/03/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

class ApiConstants: NSObject {

    //URLS
    
    static let staging = false
    
    
   
    static let BASE_URL = staging ? "https://staging.portal.g4vehiclelogistics.co.uk/" : "https://portal.g4vehiclelogistics.co.uk/"
    
    private static let API = "api/"
    private static let VERSION = "v1/"
    private static let VERSIONED_BASE = BASE_URL + API + VERSION + "driver-app/"
    
    
    public struct GETAppVersion{
        static let endPoint = VERSIONED_BASE + "get-app-version"
    }
    public struct UpdateCheck{
        static let endPoint = VERSIONED_BASE + "update/check"
    }

    public struct Login {
         static let endPoint = VERSIONED_BASE + "login"
        
        struct ReqConst {
            static let email = "email"
            static let password = "password"
        }
        
        struct ResConst {
            static let accessToken = "api_token"
            static let driverID = "driver_id"
        }
        
    }
    
    public struct Job {
        static let endpoint = VERSIONED_BASE + "jobs"
        
        struct ResConst {
            static let jobId = "id"
            static let createdAt = "created_at"
            static let updatedAt = "updated_at"
            
            static let specialInstructions = "special_instructions"
            
            static let manualAppraisalRequired = "manual_appraisal_required"
            static let videoAppraisalRequired = "video_appraisal_required"
            static let externalAppraisal = "appraisal_to_be_done_on_external_system"
            static let externalSystemName = "name_of_external_system_for_appraisal"
            
            static let collectSignature = "collect_signature"
            static let comments = "comments"
            static let companyName = "name"
            static let number1 = "telephone_1"
            static let number2 = "telephone_2"
            
            static let suggestedOrder = "suggested_order"
            static let scanned = "scanned"
            static let fleetPaperworkRequired = "fleet_paperwork_required"
            static let lastOpened = "last_opened"
            
            static let dropoffAddress = "dropoff_address"
            static let pickupAddress = "pickup_address"
            
            
            static let dropoffMonth = "dropoff_month"
            static let dropoffDay = "dropoff_day"
            static let dropoffYear = "dropoff_year"
            static let pickupMonth = "pickup_month"
            static let pickupDay = "pickup_day"
            static let pickupYear = "pickup_year"
            
            static let dropoffPreposition = "dropoff_preposition"
            static let pickupPreposition = "pickup_preposition"
            static let pickupTime = "pickup_time"
            static let dropoffTime = "dropoff_time"
            static let status = "status"
            
            
            static let houseNameNumber = "house_number_or_name"
            static let addressLine1 = "address_line_1"
            static let addressLine2 = "address_line_2"
            static let addressLine3 = "address_line_3"
            static let postcode = "postcode"
            static let city = "town_city"
            static let county = "county_area"
            static let country = "country"
            static let longitude = "long"
            static let lattitude = "latt"
            
            static let vehicle = "vehicle"
            static let vehicleType = "type"
            static let vehicleColour = "colour"
            static let vehicleMake = "make" 
            static let vehicleModel = "model"
            static let registrationPlate = "registration_number"
            static let vinNumber = "vin_number"
            static let slideDoor = "sliding_door"
            
            static let number_plate = "number_plate"
            static let vin = "vin"
            static let entry = "entry"
            static let label = "label"
            static let reasonForSkipping = "reason_for_skipping"
            
            static let jetWashRequired = "jet_wash_required"
        }
        
    }
    
    public struct JobStatus {
        static func getEndpoint(id:Int)->String {
            return VERSIONED_BASE + "jobs" + "/\(id)" +  "/status"
        }
        struct ReqConst {
            static let status = "status"
        }
    }
    public struct DriverStatusDetails{
        static func getEndPoint()->String{
            return VERSIONED_BASE + "driver-status"
        }
    }
    public struct JobCallDetails{
        static func getEndPoint(id:Int)->String{
            return VERSIONED_BASE + "jobs" + "/\(id)" + "/call-details"
        }
    }
    public struct Appraisal {
        static func getEndpoint(id:Int)->String {
            return VERSIONED_BASE + "jobs" + "/\(id)" + "/appraisal"
        }
    }
    
    public struct Expenses {
        static func getEndpoint(id:Int)->String {
            return VERSIONED_BASE + "jobs" + "/\(id)" + "/expenses"
        }
    }
    
    public struct AppriasalImages {
        static func getEndpoint(id:Int, filename: String)->String {
            return VERSIONED_BASE + "jobs" + "/\(id)" + "/appraisal" + "/images" + "/\(filename)"
        }
    }
    
    
    public struct ExpensesTrail{
        static func getEndpoint(userid:Int, startDate: String,endDate:String)->String {
            return VERSIONED_BASE + "driver" + "/\(userid)" + "/expense-accounts/audit-trail" + "/\(startDate)" + "/\(endDate)"
        }
    }
    public struct WagesBreakDownURL{
           static func getEndpoint(wagesID:String)->String {
               return VERSIONED_BASE + "get-wages-download-url" + "/\(wagesID)"
           }
       }
    public struct ExpensesImages {
        static func getEndpoint(id:Int, filename: String)->String {
            return VERSIONED_BASE + "jobs" + "/\(id)" + "/expenses" + "/images" + "/\(filename)"
        }
    }
    
    public struct CustomerSignature {
        static func getEndpoint(id:Int, filename: String)->String {
            return VERSIONED_BASE + "jobs" + "/\(id)" + "/customer_signature" + "/\(filename)"
        }
    }
    
    public struct FleetPaperWork {
        static func getEndpoint(id:Int, filename: String)->String {
            return VERSIONED_BASE + "jobs" + "/\(id)" + "/fleet_paperwork" + "/\(filename)"
        }
    }
    
    public struct Geolocations {
        static func getEndpoint(id:Int)->String {
            return VERSIONED_BASE + "geolocate"//VERSIONED_BASE + "jobs" + "/\(id)" + "/geolocate"//"/geolocations"
        }
    }
    
    
    public struct Messages {
        static func getUnreadMessages(driverId : Int)->String {
            return VERSIONED_BASE + "driver-messages" + "/\(driverId)" + "/unread"
        }
        
        static func getMessages(driverId : Int)->String {
            return VERSIONED_BASE + "driver-messages" + "/\(driverId)"
        }
        
        static func markAsRead(driverId : Int)->String {
            return VERSIONED_BASE + "driver-messages" + "/\(driverId)" + "/set-as-read"
        }
    }
    
    public struct Wages {
        static func getUnnapprovedWages()->String {
            return VERSIONED_BASE + "wages/driver-unapproved"
        }
        
        static func actionOnWage(wageId:Int)-> String {
            return VERSIONED_BASE + "wages/\(wageId)"
        }
        
    }
    
   
    
}
extension UIDevice {
    var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}
