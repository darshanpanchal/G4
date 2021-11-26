//
//  IndentedTextField.swift
//  G4VL
//
//  Created by Foamy iMac7 on 07/09/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class IndentedTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let padding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)//UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)//UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)//UIEdgeInsetsInsetRect(bounds, padding)
    }

}
