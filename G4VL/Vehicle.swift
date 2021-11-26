//
//  Vehicle.swift
//  G4VL
//
//  Created by Michael Miller on 17/03/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation

class Vehicle: Codable {
    let id: Int?
    let type, colour, make, model: String?
    let registrationNumber, vinNumber, slidingDoor, createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, colour, make, model
        case registrationNumber = "registration_number"
        case vinNumber = "vin_number"
        case slidingDoor = "sliding_door"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(id: Int?, type: String?, colour: String?, make: String?, model: String?, registrationNumber: String?, vinNumber: String?, slidingDoor: String?, createdAt: String?, updatedAt: String?) {
        self.id = id
        self.type = type
        self.colour = colour
        self.make = make
        self.model = model
        self.registrationNumber = registrationNumber
        self.vinNumber = vinNumber
        self.slidingDoor = slidingDoor
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
