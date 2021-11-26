//
//  Paperwork.swift
//  G4VL
//
//  Created by Michael Miller on 04/04/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

class Paperwork: NSObject,Codable {
    var photoNames : [String]
    var complete = false
    let label = "Paperwork"
    var uploadCarePhotoNames:[String]?
    
    enum CodingKeys: String, CodingKey {
        case photoNames = "photo_names"
        case uploadCarePhotoNames = "uploadcare_image_urls"
        case complete = "complete"
    }
    
    init(photoNames : [String]?, complete:Bool = false,uploadCarePhotoNames:[String]? = nil) {
        self.photoNames = photoNames ?? []
        self.complete = complete
        self.uploadCarePhotoNames = uploadCarePhotoNames
    }
    
}
