//
//  CorrectlyRenderImageView.swift
//  G4VL
//
//  Created by Foamy iMac7 on 16/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class CorrectlyRenderImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.image = self.image?.maskWithColor(color: self.tintColor)

    }
    
    
    
    
}
