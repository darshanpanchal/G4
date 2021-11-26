//
//  ManualAppraisal.swift
//  G4VL
//
//  Created by Foamy iMac7 on 23/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class ManualAppraisal: NSObject,Codable {
    

    var pickup : ManualAppraisalEntry
    var dropoff : ManualAppraisalEntry
    var label : String = "Manual Appraisal"
    
    enum CodingKeys: String, CodingKey  {
        case label, pickup, dropoff
    }
    
    init(pickupvalue : ManualAppraisalEntry?,dropoffvalue : ManualAppraisalEntry?) {
        self.pickup = pickupvalue ?? ManualAppraisalEntry(photoNames: nil, complete: nil, vehicleParts: nil, vehicleDetailSections: nil,uploadCarePhotoNames:nil,front:nil,driverside:nil,rear:nil,passengerside:nil)
        self.dropoff = dropoffvalue ?? ManualAppraisalEntry(photoNames: nil, complete: nil, vehicleParts: nil, vehicleDetailSections: nil,uploadCarePhotoNames:nil,front:nil,driverside:nil,rear:nil,passengerside:nil)
    }
    
}


class ManualAppraisalEntry: NSObject,Codable  {
    var photoNames : [String]?
    var complete : Bool
    var vehicleParts : [VehiclePart]?
    var vehicleDetailSections : [VehicleDetailSection]?
    var uploadCarePhotoNames:[String]?
    var front:Front?
    var driverside:DriverSide?
    var rear:Rear?
    var passengerside:PassengerSide?
    
    
    enum CodingKeys: String, CodingKey {
        case photoNames = "photo_names"
        case complete
        case vehicleParts = "vehicle_parts"
        case vehicleDetailSections = "vehicle_detail_section"
        case uploadCarePhotoNames = "uploadcare_image_urls"
        case rear
        case front
        case driverside = "driver_side"
        case passengerside = "passenger_side"
    }
    
    init(photoNames : [String]?, complete : Bool?, vehicleParts : [VehiclePart]?, vehicleDetailSections : [VehicleDetailSection]?,uploadCarePhotoNames:[String]?,front:Front?,driverside:DriverSide?,rear:Rear?,passengerside:PassengerSide?) {
        self.photoNames = photoNames ?? []
        self.complete = complete ?? false
        self.vehicleParts = vehicleParts
        self.vehicleDetailSections = vehicleDetailSections
        self.uploadCarePhotoNames = uploadCarePhotoNames ?? []
        self.front = front
        self.driverside = driverside
        self.rear = rear
        self.passengerside = passengerside
        
    }
    
}
// ["Front","Driver Side","Rear","Passenger Side"]
class  Front: NSObject, Codable {
    var label : String = "Front"
    var photoNames :String?
    var uploadCarePhotoNames : String?
    
    enum CodingKeys: String, CodingKey {
           case label
           case photoNames = "photo_name"
           case uploadCarePhotoNames = "uploadcare_image_url"
    }
    init(photoNames : String?,uploadCarePhotoNames:String?){
        self.photoNames = photoNames ?? ""
        self.uploadCarePhotoNames = uploadCarePhotoNames ?? ""
    }
       
}
class  DriverSide: NSObject, Codable {
    var label : String = "Driver Side"
    var photoNames :String?
    var uploadCarePhotoNames : String?
    
    enum CodingKeys: String, CodingKey {
           case label
           case photoNames = "photo_name"
           case uploadCarePhotoNames = "uploadcare_image_url"
    }
    init(photoNames : String?,uploadCarePhotoNames:String?){
        self.photoNames = photoNames ?? ""
        self.uploadCarePhotoNames = uploadCarePhotoNames ?? ""
    }
       
}
class  Rear: NSObject, Codable {
    var label : String = "Rear"
    var photoNames :String?
    var uploadCarePhotoNames : String?
    
    enum CodingKeys: String, CodingKey {
           case label
           case photoNames = "photo_name"
           case uploadCarePhotoNames = "uploadcare_image_url"
    }
    init(photoNames : String?,uploadCarePhotoNames:String?){
        self.photoNames = photoNames ?? ""
        self.uploadCarePhotoNames = uploadCarePhotoNames ?? ""
    }
       
}
class  PassengerSide: NSObject, Codable {
    var label : String = "Passenger Side"
    var photoNames :String?
    var uploadCarePhotoNames : String?
    
    enum CodingKeys: String, CodingKey {
           case label
           case photoNames = "photo_name"
           case uploadCarePhotoNames = "uploadcare_image_url"
    }
    init(photoNames : String?,uploadCarePhotoNames:String?){
        self.photoNames = photoNames ?? ""
        self.uploadCarePhotoNames = uploadCarePhotoNames ?? ""
    }
       
}
