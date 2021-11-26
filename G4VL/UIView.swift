//
//  UIView.swift
//  G4VL
//
//  Created by Michael Miller on 20/01/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.className, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(view);
    }
}
