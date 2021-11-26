//
//  Enums.swift
//  G4VL
//
//  Created by Michael Miller on 08/03/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import Foundation

public enum Preposition : String, Codable {
    case by = "by"
    case on = "on"
    case from = "from"
    case qMark = "?"
}

public enum JobStatus : String, Codable {
    case cancelled
    case declined
    case inactive
    case accepted
    case pickupAppraisalStarted = "pickup_appraisal_started"
    case pickupAppraisalComplete = "pickup_appraisal_complete"
    case dropoffAppraisalStarted = "dropoff_appraisal_started"
    case dropoffAppraisalComplete = "dropoff_appraisal_complete"
    case driving
    case completedAwaitingData = "completed_awaiting_data"
    case completed
}




enum RequestNames : String {
    case appriasal = "appriasal"
    case jobStatus = "jobStatus"
    case expenses = "expenses"
    case locations = "locations"
    case markAsRead = "markAsRead"
    case wageApproval = "wageApproval"
}



enum Identifier: String, Codable {
    case identifierSwitch = "switch"
    case notes = "notes"
    case radio = "radio"
    case slider = "slider"
    case measure = "measure"
}
