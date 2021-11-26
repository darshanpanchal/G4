//
//  GUID.swift
//  G4VL
//
//  Created by Michael Miller on 16/03/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

class GUID: NSObject {

    static let alphaNumeric = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","x","y","z","0","1","2","3","4","5","6","7","8","9"]
    
    
    static func generate()->String {
        
        let timestamp = getTimeStamp(date: Date())
        
        var guid = "\(timestamp!)"
        
        for _ in 13...20 {
            let randomIndex = Int(arc4random_uniform(UInt32(alphaNumeric.count)))
            guid.append(alphaNumeric[randomIndex])
        }
        
        return guid
    }
    
    static func getTimeStamp(date:Date) -> Int64! {
        return Int64(date.timeIntervalSince1970 * 1000)
    }
    
    
}
