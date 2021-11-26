//
//  ExpenseCell.swift
//  G4VL
//
//  Created by Michael Miller on 22/03/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

class ExpenseCell: UITableViewCell {
    
    @IBOutlet var lblDescription : UILabel!
    @IBOutlet var lblCost : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
