//
//  WaitingTime.swift
//  G4VL
//
//  Created by Michael Miller on 15/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation


class WaitingTime : NSObject,Codable {
    let label : String = "Waiting Time"
    var value : Int
    
    init(value : Int?) {
        self.value = value ?? 0
    }
}
