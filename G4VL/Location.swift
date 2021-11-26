//
//  Location.swift
//  G4VL
//
//  Created by Michael Miller on 06/06/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import Foundation

typealias Locations = [Location]

class Location : Codable, Equatable {
    let long : String
    let latt : String
    let geoLocatedAt : String
    
    enum CodingKeys: String, CodingKey {
        case long
        case latt
        case geoLocatedAt = "geolocated_at"
    }
    
    init(long:String, latt:String, geoLocatedAt:String) {
        self.latt = latt
        self.long = long
        self.geoLocatedAt = geoLocatedAt
    }
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.geoLocatedAt == rhs.geoLocatedAt && lhs.latt == rhs.latt && lhs.long == rhs.long
    }
    
    
    
    
}





