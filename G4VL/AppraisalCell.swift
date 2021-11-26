//
//  AppraisalCell.swift
//  G4VL
//
//  Created by Michael Miller on 17/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import UIKit

class AppraisalCell: UICollectionViewCell {
    
    @IBOutlet private var notRequiredLabel : UILabel!
    @IBOutlet private var externalSystemLabel : UILabel!
    @IBOutlet private var iconImageView : UIImageView!
    @IBOutlet private var titleLabel : UILabel!
    
    private var fadeWhenInComplete : Bool = true
    
    private let blueColor = UIColor(red: 58/255.0, green: 58/255.0, blue: 86/255.0, alpha: 1.0)
    
    private(set) var required : Bool = false {
        didSet {
            notRequiredLabel.isHidden = required
            if !required {
                self.alpha = 0.3
            }
        }
    }
    
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
    
    func setContent(icon:UIImage?, title:String, required:Bool = true, complete: Bool = false, fadeWhenInComplete : Bool = true, externalSystemName : String? = nil) {
        DispatchQueue.main.async {
            self.iconImageView.image = icon
            self.titleLabel.text = title
            self.fadeWhenInComplete = fadeWhenInComplete
            self.complete = complete
            
            
            if externalSystemName != nil {
                self.externalSystemLabel.text = "EXTERNAL APPRAISAL:\n \(externalSystemName!)"
                self.externalSystemLabel.isHidden = false
                self.required = false
            }
            else {
                self.externalSystemLabel.isHidden = true
                self.required = required
            }
        }
     }
    
   
    
    
    func invert(_ invert : Bool) {
        DispatchQueue.main.async {
            if invert {
                self.backgroundColor = self.blueColor
                self.iconImageView.tintColor = .white
                self.titleLabel.textColor = .white
                self.alpha = 1.0
            }
            else {
                self.backgroundColor = .white
                self.iconImageView.tintColor = self.blueColor
                self.titleLabel.textColor = self.blueColor
            }
        }
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 4.0
        self.layer.borderColor = blueColor.cgColor
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        //self.invert(false)
    }
    

}
