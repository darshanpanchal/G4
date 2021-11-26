//
//  VehicleImage
//  G4VL
//
//  Created by Foamy iMac7 on 19/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class VehicleImage: NSObject {
    var part : String?
    var mainImage : String?
    var imageLabel : String?
    var focusImage : String?
    var enable : Bool = true
    var damaged : Bool?
    var imageViewReference : UIImageView?
    var originalImage : UIImage?
    
    init(part: String?, mainImage : String, focusImage : String, enable: Bool) {
        self.part = part
        self.mainImage = mainImage
        self.enable = enable
        self.focusImage = focusImage
    }
}
