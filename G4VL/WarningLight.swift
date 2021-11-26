//
//  WarningLights.swift
//  G4VL
//
//  Created by Foamy iMac7 on 23/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class WarningLight: NSObject,Codable {
    
    var pickup : WarningLightEntry
    var dropoff : WarningLightEntry
    var label : String = "Warning Light"
    
    enum CodingKeys: String, CodingKey  {
        case label, pickup, dropoff
    }
    
    init(pickup : WarningLightEntry? = nil,dropoff : WarningLightEntry? = nil) {
        self.pickup = pickup ?? WarningLightEntry(photoNames: nil, complete: nil,uploadCarePhotoNames:nil)
        self.dropoff = dropoff ?? WarningLightEntry(photoNames: nil, complete: nil,uploadCarePhotoNames:nil)
    }
    
}


