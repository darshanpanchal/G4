//
//  NSObject.swift
//  G4VL
//
//  Created by Michael Miller on 20/01/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation


extension NSObject {
    
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
    
}
