//
//  Mileage.swift
//  G4VL
//
//  Created by Foamy iMac7 on 23/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class Mileage: NSObject,Codable {
    
    var pickup : MileagePetrolEntry
    var dropoff : MileagePetrolEntry
    var label : String
    
    enum CodingKeys: String, CodingKey  {
        case label, pickup, dropoff
    }
    
    init(label:String, pickup : MileagePetrolEntry? = nil,dropoff : MileagePetrolEntry? = nil) {
        self.pickup = pickup ?? MileagePetrolEntry(manualEntry: nil, photoNames: nil, complete: nil,uploadCarePhotoNames:nil)
        self.dropoff = dropoff ?? MileagePetrolEntry(manualEntry: nil, photoNames: nil, complete: nil,uploadCarePhotoNames:nil)
        self.label = label
    }
    
}
