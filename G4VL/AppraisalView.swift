//
//  AppraisalView.swift
//  G4VL
//
//  Created by Michael Miller on 13/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import UIKit

protocol AppraisalViewDelegate {
    func tapped(appraisalView : AppraisalView)
}

class AppraisalView: UIControl {

    @IBOutlet private var notRequiredLabel : UILabel!
    @IBOutlet private var iconImageView : UIImageView!
    @IBOutlet private var titleLabel : UILabel!
    var delegate : AppraisalViewDelegate?
    
    private var fadeWhenInComplete : Bool = true
    
    private let blueColor = UIColor(red: 58/255.0, green: 58/255.0, blue: 86/255.0, alpha: 1.0)
    
    private(set) var complete : Bool = false {
        didSet {
            if complete {
                self.invert(false)
                self.alpha = 1.0
            }
            else {
                if fadeWhenInComplete {
                    self.alpha = 0.3
                }
            }
        }
    }
    
    private(set) var required : Bool = false {
        didSet {
            notRequiredLabel.isHidden = required
            if !required {
                self.alpha = 0.3
            }
        }
    }
    
    func setContent(icon:UIImage?, title:String, required:Bool = true, complete: Bool = false, fadeWhenInComplete : Bool = true) {
        iconImageView.image = icon
        titleLabel.text = title
        
        self.fadeWhenInComplete = fadeWhenInComplete
        self.complete = complete
        self.required = required
    }
    
    func invert(_ invert : Bool) {
        
        if invert {
            self.backgroundColor = blueColor
            iconImageView.tintColor = .white
            titleLabel.textColor = .white
            self.alpha = 1.0
        }
        else {
            self.backgroundColor = .white
            iconImageView.tintColor = blueColor
            titleLabel.textColor = blueColor
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        sharedInit()
    }

    
    private func sharedInit() {
        loadViewFromNib()
        
        self.layer.borderWidth = 4.0
        self.layer.borderColor = blueColor.cgColor
    }
    
    
    @IBAction func tapped() {
        self.delegate?.tapped(appraisalView: self)
    }
}
