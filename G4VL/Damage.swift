//
//  Damages.swift
//  G4VL
//
//  Created by Foamy iMac7 on 24/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class Damage: Codable {
    let label: String?
    var state: Bool?
    let identifier: Identifier?
    var text : String?
    var options : [String]?
    var selected : Int?
    
    init(label: String?, state: Bool?, identifier: Identifier?,text : String?, options : [String]?, selected : Int?) {
        self.label = label
        self.state = state ?? false
        self.identifier = identifier
        self.text = text
        self.options = options
        self.selected = selected ?? 0
    }
}
