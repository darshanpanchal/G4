//
//  PhotoCell.swift
//  G4VL
//
//  Created by Foamy iMac7 on 21/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

protocol PhotoCellDelegate {
    func removeImageWithFilename(filename:String)
}

class PhotoCell: UICollectionViewCell {
    var delegate : PhotoCellDelegate?
    @IBOutlet var buttonDelete : UIButton!
    @IBOutlet var imageView : UIImageView!
    var filename = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = true
        
        self.backgroundColor = UIColor.white
        
        
    }
    
    @IBAction func removeImage() {
        
        delegate?.removeImageWithFilename(filename:filename)
    }
    
}
