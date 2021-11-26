//
//  DashCell.swift
//  G4VL
//
//  Created by Foamy iMac7 on 18/10/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class DashCell: UITableViewCell {
    
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var lblDescription : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
