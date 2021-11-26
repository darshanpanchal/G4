//
//  ExtrasEntry.swift
//  G4VL
//
//  Created by Michael Miller on 15/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation



class ExtraEntry  : NSObject,Codable  {
    var waitingTime : WaitingTime
    var complete : Bool
    
    
    enum CodingKeys: String, CodingKey  {
        case complete
        case waitingTime = "waiting_time"
    }
    
    init(waitingTime : WaitingTime?, complete:Bool?) {
        self.waitingTime = waitingTime ?? WaitingTime(value: nil)
        self.complete = complete ?? false
    }
    
    
}
