//
//  CustomAlert.swift
//  G4VL
//
//  Created by Foamy iMac7 on 18/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class CustomAlert: UIView {

    @IBOutlet var titleLabel : UILabel!
    var yesCompletionHandler : ()->Void = {}
    var noCompletionHandler : ()->Void = {}
    @IBOutlet var v : UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self {
            hide()
        }
    }
    
    
    static func instanceFromNib() -> UIView {
        
        
        
        return UINib(nibName: "CustomAlert", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    
    @IBAction private func tappedYes() {
        yesCompletionHandler()
    }
    
    @IBAction private func tappedNo() {
        noCompletionHandler()
    }
    
    func show() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
            self.removeFromSuperview()
        })
    }

}
