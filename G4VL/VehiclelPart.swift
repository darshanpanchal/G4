//
//  VehicalPart.swift
//  G4VL
//
//  Created by Foamy iMac7 on 23/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit


typealias VehicleParts = [VehiclePart]

class VehiclePart: Codable {
    var name, key, label: String?
    var damages: [Damage]?
    var checked : Bool!
    var notes : String?
    var photoNames : [String]?
    var uploadCarePhotoNames:[String]?
    enum CodingKeys: String, CodingKey  {
        case name, key, label, damages,checked, notes
        case photoNames = "photo_names"
        case uploadCarePhotoNames = "uploadcare_image_urls"
    }
    
    init(name: String?, key: String?, label: String?, damages: [Damage]?, notes : String?, photoNames : [String]?, checked : Bool? = false,uploadCarePhotoNames : [String]?) {
        self.name = name
        self.key = key
        self.label = label
        self.damages = damages
        self.notes = notes
        self.photoNames = photoNames ?? []
        self.checked = checked
        self.uploadCarePhotoNames = uploadCarePhotoNames ?? []
    }
    
    func removeDamage() {
        if damages != nil {
            for d in damages! {
                d.state = false
                d.selected = 0;
            }
        }
        
    }
}


