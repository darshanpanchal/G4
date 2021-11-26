//
//  FailedRequest.swift
//  G4VL
//
//  Created by Michael Miller on 01/06/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import Foundation

typealias FailedRequests = [FailedRequest]

class FailedRequest : Codable, Equatable {
    let driverID :Int
    let jobID : Int?
    let wageID : Int?
    let approve : Bool?
    let reason: String?
    let messageID : Int?
    let request : String
    let status : String?
    let locations : Data?
    
    enum CodingKeys: String, CodingKey {
        case jobID
        case wageID
        case approve
        case reason
        case driverID
        case messageID
        case request
        case status
        case locations
    }
    
    init(driverID : Int, jobID : Int?, messageID : Int?, wageID : Int?, approve : Bool?, reason:String?, request : String, status : String?, locations : Data?) {
        self.driverID = driverID
        self.jobID = jobID
        self.messageID = messageID
        self.request = request
        self.status = status
        self.locations = locations
        self.wageID = wageID
        self.approve = approve
        self.reason = reason
    }
    
    static func == (lhs: FailedRequest, rhs: FailedRequest) -> Bool {
        return lhs.driverID == rhs.driverID
            && lhs.jobID == rhs.jobID
            && lhs.request == rhs.request
            && lhs.status == rhs.status
            && lhs.locations == rhs.locations
            && lhs.messageID == rhs.messageID
            && lhs.wageID == rhs.wageID
            && lhs.approve == rhs.approve
            && lhs.reason == rhs.reason
        
    }
}
