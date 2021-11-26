//
//  Signatures.swift
//  G4VL
//
//  Created by Michael Miller on 04/04/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

class Signatures : NSObject,Codable {

    
    var pickup : SignatureEntry?
    var dropoff : SignatureEntry?
    var label : String = "Signature"
    
    enum CodingKeys: String, CodingKey  {
        case label, pickup, dropoff
    }
    
    init(pickup : SignatureEntry?,dropoff : SignatureEntry?) {
        self.pickup = pickup ?? SignatureEntry(label: "Pickup", signatureFileName: nil, signedBy: nil, dateSigned: nil, uploadcareImageUrl: nil)
        self.dropoff = dropoff ?? SignatureEntry(label: "Dropoff",signatureFileName: nil, signedBy: nil, dateSigned: nil, uploadcareImageUrl: nil)
    }
    
    
    
}
