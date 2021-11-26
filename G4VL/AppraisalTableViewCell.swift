//
//  AppraisalTableViewCell.swift
//  G4VL
//
//  Created by IPS on 17/08/20.
//  Copyright © 2020 Foamy iMac7. All rights reserved.
//

import UIKit

protocol AppraisalCellDelegate {
    func buttonImagePickerSelector(tag:Int)
}
class AppraisalTableViewCell: UITableViewCell {

    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var imageViewVehicle:UIImageView!
    @IBOutlet var buttonImageVehicle:UIButton!
    
    var delegate:AppraisalCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    @IBAction func buttonImagePicker(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonImagePickerSelector(tag: sender.tag)
        }
    }
}
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
