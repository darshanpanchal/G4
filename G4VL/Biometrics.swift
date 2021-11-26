//
//  Biometrics.swift
//  G4VL
//
//  Created by Michael Miller on 05/06/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import Foundation
import LocalAuthentication

class Biometrics {
    
    enum BioType {
        case kFace
        case kTouch
        case kNone
    }
    
    static func checkForBiometry(context:LAContext) -> BioType {
        
       
        if #available(iOS 11.0, *),context.responds(to: #selector(getter: LAContext.biometryType))  {
            
            if context.biometryType == .faceID {
                
                return .kFace
            }
            else if context.biometryType == .touchID {
                return .kTouch
            }
        }
        return .kNone
    }
    
}


