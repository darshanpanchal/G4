//
//  JobCell.swift
//  G4VL
//
//  Created by Foamy iMac7 on 25/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import SwipeCellKit

class JobCell: SwipeTableViewCell {
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var destinationLabel : UILabel!
    @IBOutlet var dateLabel : UILabel!
    @IBOutlet var carTypeLabel : UILabel!
    @IBOutlet var lblJOBID:UILabel!
    @IBOutlet var dropOffDetail:UILabel!
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
       
        
    }
    
   
    
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        
            super.setSelected(selected, animated: animated)
            
    }


}
