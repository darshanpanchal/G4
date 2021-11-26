//
//  Extras.swift
//  G4VL
//
//  Created by Michael Miller on 05/07/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import Foundation


class Extras : NSObject,Codable {
    
    var pickup : ExtraEntry
    var dropoff : ExtraEntry
    var label : String = "Extras"
    
    enum CodingKeys: String, CodingKey  {
        case label, pickup, dropoff
    }
    
    init(pickup : ExtraEntry? = nil,dropoff : ExtraEntry? = nil) {
        self.pickup = pickup ?? ExtraEntry(waitingTime: nil, complete: nil)
        self.dropoff = dropoff ?? ExtraEntry(waitingTime: nil, complete: nil)
    }
    
    
}


