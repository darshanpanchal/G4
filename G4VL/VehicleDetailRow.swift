//
//  VehicleDetailRow.swift
//  G4VL
//
//  Created by Foamy iMac7 on 24/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class VehicleDetailRow: Codable {
    let label, key: String?
    let options: [String]?
    var selected: Int?
    let identifier: Identifier?
    let max, min, step: Int?
    var value: Double!
    var state: Bool?
    let units : String?
    let desc : String?
    var text : String?
    
    init(label: String?, key: String?, options: [String]?, selected: Int?, identifier: Identifier?, max: Int?, min: Int?, step: Int?, value: Double? = 0.0, state: Bool?, units : String?, desc : String?, text : String?) {
        self.label = label
        self.key = key
        self.options = options
        self.selected = selected
        self.identifier = identifier
        self.max = max
        self.min = min
        self.step = step
        self.value = value ?? 0.0
        self.state = state
        self.units = units
        self.desc = desc
        self.text = text
    }
}
