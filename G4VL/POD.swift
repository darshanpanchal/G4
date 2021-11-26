//
//  POD.swift
//  G4VL
//
//  Created by Michael Miller on 18/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation


class POD: NSObject, Codable  {
    
    var jobID : Int?
    var createdAt : String?
    var updatedAt : String?
    var status: JobStatus = .inactive
    
    enum CodingKeys: String, CodingKey {
        case jobId = "id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case numberPlate = "number_plate"
        case manualAppraisal = "manual_appraisal"
        case videoAppraisal = "video_appraisal"
        case petrolLevel = "petrol_level"
        case warningLight = "warning_light"
        case signatures = "customer_signatures"
        case specialInstructionsComplete = "special_instructions_complete"
        case vin, extras, status, mileage,paperwork, expenses,appVersion
    }
    
    var manualAppraisal : PODManualAppraisal?
    var numberPlate : NumberPlate?
    var vin : VIN?
    var videoAppraisal : VideoAppraisal?
    var petrolLevel : PetrolLevel?
    var mileage : Mileage?
    var warningLight : WarningLight?
    var paperwork : Paperwork?
    var signatures : Signatures?
    var expenses : [Expense] = []
    var extras : Extras?
    var specialInstructionsComplete : Bool?
    var appVersion:String?
        
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        jobID = try values.decode(Int.self, forKey: .jobId)
        createdAt = try values.decode(String?.self, forKey: .createdAt)
        updatedAt = try values.decode(String?.self, forKey: .updatedAt)
        status = try values.decode(JobStatus.self, forKey: .status)
        numberPlate = try values.decode(NumberPlate?.self, forKey: .numberPlate)
        vin = try values.decode(VIN?.self, forKey: .vin)
        manualAppraisal = try values.decode(PODManualAppraisal.self, forKey: .manualAppraisal)
        videoAppraisal = try values.decode(VideoAppraisal?.self, forKey: .videoAppraisal)
        petrolLevel = try values.decode(PetrolLevel?.self, forKey: .petrolLevel)
        mileage = try values.decode(Mileage?.self, forKey: .mileage)
        warningLight = try values.decode(WarningLight?.self, forKey: .warningLight)
        paperwork = try values.decode(Paperwork?.self, forKey: .paperwork)
        signatures = try values.decode(Signatures?.self, forKey: .signatures)
        expenses = try values.decode([Expense].self, forKey: .expenses)
        extras = try values.decode(Extras?.self, forKey: .extras)
        specialInstructionsComplete = try values.decode(Bool?.self, forKey: .specialInstructionsComplete)
        appVersion = try values.decode(String?.self, forKey: .appVersion)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jobID, forKey: .jobId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(status, forKey: .status)
        try container.encode(numberPlate, forKey: .numberPlate)
        try container.encode(vin, forKey: .vin)
        try container.encode(manualAppraisal, forKey: .manualAppraisal)
        try container.encode(videoAppraisal, forKey: .videoAppraisal)
        try container.encode(petrolLevel, forKey: .petrolLevel)
        try container.encode(mileage, forKey: .mileage)
        try container.encode(warningLight, forKey: .warningLight)
        try container.encode(paperwork, forKey: .paperwork)
        try container.encode(signatures, forKey: .signatures)
        try container.encode(expenses, forKey: .expenses)
        try container.encode(extras, forKey: .extras)
        try container.encode(specialInstructionsComplete, forKey: .specialInstructionsComplete)
        try container.encode(appVersion, forKey: .appVersion)

    }
   
    
    init(jobAppraisal : JobAppraisal) {
        self.appVersion = "\(Bundle.main.versionNumber) (\(Bundle.main.buildNumber)) iOS"
        self.jobID = jobAppraisal.jobID
        self.createdAt = jobAppraisal.createdAt
        self.updatedAt = jobAppraisal.updatedAt
        self.status = jobAppraisal.status
        self.numberPlate = jobAppraisal.numberPlate
        self.vin  = jobAppraisal.vin
        self.videoAppraisal = jobAppraisal.videoAppraisal
        self.petrolLevel = jobAppraisal.petrolLevel
        self.mileage = jobAppraisal.mileage
        self.warningLight = jobAppraisal.warningLight
        self.paperwork = jobAppraisal.paperwork
        self.signatures = jobAppraisal.signatures
        self.expenses = jobAppraisal.expenses
        self.extras = jobAppraisal.extras
        self.specialInstructionsComplete = jobAppraisal.specialInstructionsComplete
        
        if jobAppraisal.manualAppraisal != nil {
            
        
            
            let entries : [ManualAppraisalEntry] = [jobAppraisal.manualAppraisal!.pickup, jobAppraisal.manualAppraisal!.dropoff]
            var pickup : PODManualAppraisalEntry?
            var dropoff : PODManualAppraisalEntry?
            
            var counter = 0
            for entry in entries {
                
                
                var vehicleInfo : PODVehicleInfos = [:]
                if entry.vehicleDetailSections != nil {
                    for section in entry.vehicleDetailSections! {
                        
                        if section.vehicleDetailRows != nil {
                        
                            for row in section.vehicleDetailRows! {
                                
                                var key = ""
                                var value = ""
                                var label = ""
                                
                                switch row.identifier! {
                                case .radio:
                                    key = row.key!
                                    label = row.label ?? ""
                                    if row.options != nil && row.selected != nil {
                                        value = row.options![row.selected!-1]
                                    }
                                case .identifierSwitch:
                                    key = row.key!
                                    label = row.label ?? ""
                                    value = row.state! ? "Yes" : "No"
                                case .measure:
                                    key = row.key!
                                    label = row.label ?? ""
                                    value = "\(row.value ?? 0.0) \(row.units!)"
                                case .notes:
                                    key = row.key!
                                    label = row.label ?? ""
                                    value = row.text ?? ""
                                case .slider:
                                    key = row.key!
                                    label = row.label ?? ""
                                    value = "\(Int(row.value))"
                                }
                                
                                vehicleInfo[key] = PODVehicleInfo(label: label, values: [value])
                            }
                        }
                        
                    }
                }
                
                
                if entry.photoNames != nil {
                    vehicleInfo["photo_names"] = PODVehicleInfo(label: "General Photos", values: entry.photoNames!)
                }
                if entry.uploadCarePhotoNames != nil {
                    vehicleInfo["uploadcare_image_urls"] = PODVehicleInfo(label: "UploadCare Photos", values: entry.uploadCarePhotoNames!)
                }
                
                var vehicleParts  : PODVehicleParts = [:]
                
                if entry.vehicleParts != nil {
                    for part in entry.vehicleParts! {
                        
                        
                        
                        let key =  part.key!
                        let notes = part.notes ?? ""
                        let photos = part.photoNames ?? []
                        let uploadCarePhotos = part.uploadCarePhotoNames ?? []
                        
                        
                        var damages : [String] = []
                        
                        if part.damages != nil && part.damages!.count != 0 {
                            for damage in part.damages! {
                                
                                if damage.state != nil && damage.state! {
                                    damages.append(damage.label ?? damage.text!)
                                }
                                
                                
                            }
                        }
                        
                        
                        let d = PODDamages(label: "Damages", values: damages)
                        
                        let vp = PODVehiclePart(label: part.label ?? "", damages: d, photoNames: photos, notes:notes,uploadCareImages:uploadCarePhotos)
                        
                        
                        
                        vehicleParts[key]  =  vp
                        
                    }
                }
                
                
                if counter == 0 {
                    
                    pickup = PODManualAppraisalEntry(label: "Pickup", vehicleInfo: vehicleInfo, vehicleParts: vehicleParts,front:jobAppraisal.manualAppraisal?.pickup.front,driverside:jobAppraisal.manualAppraisal?.pickup.driverside,rear:jobAppraisal.manualAppraisal?.pickup.rear,passengerside:jobAppraisal.manualAppraisal?.pickup.passengerside)
                }
                else {
                    dropoff = PODManualAppraisalEntry(label: "Dropoff", vehicleInfo: vehicleInfo, vehicleParts: vehicleParts,front:jobAppraisal.manualAppraisal?.dropoff.front,driverside:jobAppraisal.manualAppraisal?.dropoff.driverside,rear:jobAppraisal.manualAppraisal?.dropoff.rear,passengerside:jobAppraisal.manualAppraisal?.dropoff.passengerside)
                }
                
                counter += 1
            }
            
            self.manualAppraisal = PODManualAppraisal(pickup: pickup!, dropoff: dropoff!)
        }
            
        
    }
    
}




class PODManualAppraisal : NSObject, Codable  {
    
    var pickup : PODManualAppraisalEntry
    var dropoff : PODManualAppraisalEntry
    
    enum CodingKeys: String, CodingKey {
        case pickup, dropoff
    }
    
    init(pickup : PODManualAppraisalEntry, dropoff : PODManualAppraisalEntry) {
        self.pickup = pickup
        self.dropoff = dropoff
    }
    
}

class PODManualAppraisalEntry : NSObject, Codable  {
    let label : String
    let vehicleInfo : PODVehicleInfos
    let vehicleParts : PODVehicleParts
    var front:Front?
    var driverside:DriverSide?
    var rear:Rear?
    var passengerside:PassengerSide?
    
    
    enum CodingKeys: String, CodingKey {
        case label
        case vehicleInfo = "vehicle_info"
        case vehicleParts = "vehicle_parts"
        case rear
        case front
        case driverside = "driver_side"
        case passengerside = "passenger_side"
    }
    init(label : String, vehicleInfo : PODVehicleInfos, vehicleParts : PODVehicleParts,front:Front?,driverside:DriverSide?,rear:Rear?,passengerside:PassengerSide?) {
        self.label = label
        self.vehicleInfo = vehicleInfo
        self.vehicleParts = vehicleParts
         self.front = front
         self.driverside = driverside
         self.rear = rear
         self.passengerside = passengerside
    }
    
}



typealias PODVehicleInfos = [String:PODVehicleInfo]

class PODVehicleInfo : NSObject, Codable  {
    let label : String
    let values : [String]
    
    enum CodingKeys: String, CodingKey {
        case label, values
    }
    
    init(label : String,values : [String] ) {
        self.label = label
        self.values = values
    }
}


typealias PODVehicleParts = [String:PODVehiclePart]

class PODVehiclePart : NSObject, Codable  {
    let label: String?
    let damages: PODDamages?
    let photoNames: [String]?
    let notes : String?
    let uploadCareImages:[String]?
//    let offlineImages:[String]?
    
    enum CodingKeys: String, CodingKey {
        case label, damages, notes//,offlineImages
        case photoNames = "photo_names"
        case uploadCareImages = "uploadcare_image_urls"
        
    }
    init(label: String?, damages: PODDamages?, photoNames: [String]?, notes: String?,uploadCareImages:[String]?) {
        self.label = label
        self.damages = damages
        self.photoNames = photoNames
        self.notes = notes
        self.uploadCareImages = uploadCareImages
//        self.offlineImages = []
    }
}

class PODDamages : NSObject, Codable  {
    let label: String?
    let values: [String]?
    
    init(label: String?, values: [String]?) {
        self.label = label
        self.values = values
    }
}





