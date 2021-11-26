//
//  VideoAppraisalEntry.swift
//  G4VL
//
//  Created by Michael Miller on 15/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation

class VideoAppraisalEntry: NSObject,Codable {
    var videos : [Video]
    
    var complete : Bool
    
    enum CodingKeys: String, CodingKey {
        case videos
        case complete
    }
    
    init(videos : [Video]?, complete : Bool?) {
        self.videos = videos ?? []
        self.complete = complete ?? false
    }
    
    class Video : Equatable, Codable {
        static func == (lhs: VideoAppraisalEntry.Video, rhs: VideoAppraisalEntry.Video) -> Bool {
            return lhs.videoName == rhs.videoName && lhs.vimeoLink == rhs.vimeoLink
        }
        
        var videoName : String?
        var vimeoLink : String
        
        enum CodingKeys: String, CodingKey {
            case videoName = "video_name"
            case vimeoLink = "vimeo_link"
        }
        
        init(videoName : String?,vimeoLink : String?) {
            self.videoName = videoName
            self.vimeoLink = vimeoLink ?? ""
        }
    }
}
