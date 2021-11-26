//
//  JSONCodingKey.swift
//  G4VL
//
//  Created by Michael Miller on 18/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation




class JSONCodingKey: CodingKey {
    let key: String
    
    required init?(intValue: Int) {
        return nil
    }
    
    required init?(stringValue: String) {
        key = stringValue
    }
    
    var intValue: Int? {
        return nil
    }
    
    var stringValue: String {
        return key
    }
}
