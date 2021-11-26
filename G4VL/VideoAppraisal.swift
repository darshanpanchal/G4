//
//  VideoAppraisal.swift
//  G4VL
//
//  Created by Foamy iMac7 on 23/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class VideoAppraisal: NSObject,Codable {
    
    var pickup : VideoAppraisalEntry
    var dropoff : VideoAppraisalEntry
    var label : String = "Video Appraisal"
    
    enum CodingKeys: String, CodingKey  {
        case label, pickup, dropoff
    }
    
    init(pickup : VideoAppraisalEntry? = nil,dropoff : VideoAppraisalEntry? = nil) {
        self.pickup = pickup ?? VideoAppraisalEntry(videos: nil, complete: nil)
        self.dropoff = dropoff ?? VideoAppraisalEntry(videos: nil, complete: nil)
    }

}


