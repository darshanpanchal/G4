//
//  SignatureTableViewCell.swift
//  G4VL
//
//  Created by Michael Miller on 04/06/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

protocol SignatureTableViewCellDelegate {
    func clear()
    func confirm()
    func buttonImagePickerSelector(tag:Int)
}

class SignatureTableViewCell: UITableViewCell {
    
    @IBOutlet private var nameLabel: UILabel!
    var delegate : SignatureTableViewCellDelegate?
    @IBOutlet var signView : SignView!
    @IBOutlet weak var imageUploadContainerView:UIView!
    
    @IBOutlet var imageViewVehicle:UIImageView!
    @IBOutlet var buttonImageVehicle:UIButton!
    var appManager = AppManager.sharedInstance
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameLabel.text = "Your driver today is \(AppManager.sharedInstance.currentUser!.driverName ?? "")\n\nDisclaimer:- \(appManager.currentJob!.customer?.disclaimer ?? "")"
                        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clear() {
        self.delegate?.clear()
    }
    
    @IBAction func confirm() {
        self.delegate?.confirm()
    }
    @IBAction func buttonCameraImagePicker(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonImagePickerSelector(tag: sender.tag)
        }
    }
}
