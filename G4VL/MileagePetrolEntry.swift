//
//  Entry.swift
//  G4VL
//
//  Created by Michael Miller on 02/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation


class MileagePetrolEntry : NSObject,Codable {
    var manualEntry : String
    var complete : Bool
    var photoNames : [String]
//    var offlineNames:[String]?
    var uploadCarePhotoNames:[String]?

    enum CodingKeys: String, CodingKey  {
        case manualEntry = "entry"
        case complete
//        case offlineNames = "photo_names"
        case photoNames = "photo_names"//"offline_image_names"//
        case uploadCarePhotoNames = "uploadcare_image_urls"
    }
    
    init(manualEntry : String? = nil ,photoNames : [String]? = nil,offlineNames:[String]? = nil, complete : Bool? = nil,uploadCarePhotoNames : [String]?) {
        self.manualEntry = manualEntry ?? ""
        self.complete = complete ?? false
//        self.offlineNames = []
        self.photoNames = photoNames ?? []
        self.uploadCarePhotoNames = uploadCarePhotoNames ?? []
    }
}
