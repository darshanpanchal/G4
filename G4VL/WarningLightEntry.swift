//
//  WarningLightEntry.swift
//  G4VL
//
//  Created by Michael Miller on 15/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation

class WarningLightEntry : NSObject,Codable {
    var photoNames : [String]
    var complete = false
    var uploadCarePhotoNames:[String]?
    
    enum CodingKeys: String, CodingKey  {
        case complete 
        case photoNames = "photo_names"
        case uploadCarePhotoNames = "uploadcare_image_urls"
    }
    
    init(photoNames : [String]?,complete :Bool?,uploadCarePhotoNames:[String]?) {
        self.photoNames = photoNames ?? []
        self.complete = complete ?? false
        self.uploadCarePhotoNames = uploadCarePhotoNames ?? []
    }
}
