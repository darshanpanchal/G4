//
//  VIN.swift
//  G4VL
//
//  Created by Michael Miller on 18/04/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

class VIN: NSObject,Codable {
    var pickup : PlateVinEntry
    var dropoff : PlateVinEntry
    var label : String = "VIN"
    
    enum CodingKeys: String, CodingKey  {
        case label, pickup, dropoff
    }
    
    init(pickup : PlateVinEntry? = nil,dropoff : PlateVinEntry? = nil) {
        self.pickup = pickup ?? PlateVinEntry(label:"VIN", entry: nil, reasonForSkipping: nil)
        self.dropoff = dropoff ?? PlateVinEntry(label: "VIN", entry: nil, reasonForSkipping: nil)
    }
}

