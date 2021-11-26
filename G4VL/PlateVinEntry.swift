//
//  PlateVinEntry.swift
//  G4VL
//
//  Created by Michael Miller on 15/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation

class PlateVinEntry : NSObject,Codable {
    var label : String
    var entry : Entry
    var reasonForSkipping : String
    var photoName:String
    var uploadCarePhotoName:String
    
    enum CodingKeys: String, CodingKey {
        case label
        case entry
        case reasonForSkipping = "reason_for_skipping"
        case photoName = "photo_name"
        case uploadCarePhotoName = "uploadcare_image_url"
    }
    
    
    
    init(label : String, entry : Entry?, reasonForSkipping : String?,photoName:String? = nil,uploadCarePhotoName:String? = nil) {
        self.label = label
        self.entry = entry ?? .nothing
        self.reasonForSkipping = reasonForSkipping ?? ""
        self.photoName = photoName ?? ""
        self.uploadCarePhotoName = uploadCarePhotoName ?? ""
    }
}

enum Entry : String, Codable {
    case nothing = ""
    case manual = "manual"
    case skipped = "skipped"
    case scanned = "scanned"
}
