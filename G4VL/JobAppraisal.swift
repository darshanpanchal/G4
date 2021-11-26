//
//  Job.swift
//  G4VL
//
//  Created by Foamy iMac7 on 23/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit


class JobAppraisal:NSObject, Codable {
    
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
        case vin, extras, status, mileage,paperwork, expenses
        case noJetWashReason = "provided_no_jet_wash_reason"
    }

    var numberPlate : NumberPlate?
    var vin : VIN?
    var manualAppraisal : ManualAppraisal?
    var videoAppraisal : VideoAppraisal?
    var petrolLevel : PetrolLevel?
    var mileage : Mileage?
    var warningLight : WarningLight?
    var paperwork : Paperwork?
    var signatures : Signatures?
    var expenses : [Expense] = []
    var extras : Extras?
    var specialInstructionsComplete : Bool?
    var noJetWashReason : String?
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        jobID = try values.decode(Int.self, forKey: .jobId)
        createdAt = try values.decode(String?.self, forKey: .createdAt)
        updatedAt = try values.decode(String?.self, forKey: .updatedAt)
        status = try values.decode(JobStatus.self, forKey: .status)
        numberPlate = try values.decode(NumberPlate?.self, forKey: .numberPlate)
        vin = try values.decode(VIN?.self, forKey: .vin)
        manualAppraisal = try values.decode(ManualAppraisal?.self, forKey: .manualAppraisal)
        videoAppraisal = try values.decode(VideoAppraisal?.self, forKey: .videoAppraisal)
        petrolLevel = try values.decode(PetrolLevel?.self, forKey: .petrolLevel)
        mileage = try values.decode(Mileage?.self, forKey: .mileage)
        warningLight = try values.decode(WarningLight?.self, forKey: .warningLight)
        paperwork = try values.decode(Paperwork?.self, forKey: .paperwork)
        signatures = try values.decode(Signatures?.self, forKey: .signatures)
        expenses = try values.decode([Expense].self, forKey: .expenses)
        extras = try values.decode(Extras?.self, forKey: .extras)
        specialInstructionsComplete = try values.decode(Bool?.self, forKey: .specialInstructionsComplete)
        noJetWashReason = try values.decode(String?.self, forKey: .noJetWashReason)
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
        try container.encode(noJetWashReason, forKey: .noJetWashReason)
    }
    
    init(jobID : Int?,createdAt : String?,updatedAt : String?,numberPlate:NumberPlate?,vin : VIN?,status: JobStatus,manualAppraisal : ManualAppraisal?,petrolLevel : PetrolLevel?,mileage : Mileage?,warningLight : WarningLight?,paperwork : Paperwork?,signatures : Signatures?,expenses : [Expense],extras : Extras?,videoAppraisal : VideoAppraisal?, specialInstructionsComplete : Bool? = nil, noJetWashReason : String? = nil) {
        self.jobID = jobID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status
        self.numberPlate = numberPlate ?? NumberPlate(pickup: nil, dropoff: nil)
        self.vin  = vin ?? VIN(pickup: nil, dropoff: nil)
        self.manualAppraisal = manualAppraisal
        self.videoAppraisal = videoAppraisal
        self.petrolLevel = petrolLevel ?? PetrolLevel(label: "Petrol")
        self.mileage = mileage ?? Mileage(label: "Mileage")
        self.warningLight = warningLight ?? WarningLight(pickup: nil, dropoff: nil)
        self.paperwork = paperwork
        self.signatures = signatures
        self.expenses = expenses
        self.extras = extras ?? Extras(pickup: nil, dropoff: nil)
        self.specialInstructionsComplete = specialInstructionsComplete
        self.noJetWashReason = noJetWashReason
    }
    
    init(id:Int) {
        
        self.jobID = id
        self.numberPlate = NumberPlate(pickup: nil, dropoff: nil)
        self.vin  =  VIN(pickup: nil, dropoff: nil)
    }
    
    
    func copyPickUpToDropOff() {
        
        numberPlate!.dropoff = numberPlate!.pickup
        
        
        if let currentmanualAppraisal = self.manualAppraisal {
            
            let objManualAppraisal = ManualAppraisal.init(pickupvalue: currentmanualAppraisal.pickup, dropoffvalue: nil)
            
            objManualAppraisal.dropoff.complete = false
            objManualAppraisal.dropoff.photoNames = objManualAppraisal.pickup.photoNames
            objManualAppraisal.dropoff.vehicleParts = objManualAppraisal.pickup.vehicleParts
            objManualAppraisal.dropoff.vehicleDetailSections = objManualAppraisal.pickup.vehicleDetailSections
            objManualAppraisal.dropoff.uploadCarePhotoNames = objManualAppraisal.pickup.uploadCarePhotoNames
            
            self.manualAppraisal = objManualAppraisal
            
        }
        
        
    }
    
}














