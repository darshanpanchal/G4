//
//  DriverDocument.swift
//  G4VL
//
//  Created by Michael Miller on 17/03/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation

class DriverDocument : Codable {
    
    let id, jobId, userId, driverId : Int?
    let createdAt, updatedAt, label, filename, type,desc : String?
    
    enum CodingKeys: String, CodingKey {
        case id, label,filename, type
        case jobId = "job_id"
        case userId = "driver_id"
        case driverId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case desc = "description"
    }
    
    
    init(id : Int?,jobId : Int?,userId : Int?,driverId : Int?,createdAt : String?,updatedAt : String?,label : String?,filename : String?,type : String?,desc : String?) {
        self.id = id
        self.jobId = jobId
        self.userId = userId
        self.driverId = driverId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.label = label
        self.filename = filename
        self.type = type
        self.desc = desc
    }
    
}
