//
//  ExpenseTrailTableViewCell.swift
//  G4VL
//
//  Created by user on 05/11/19.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import UIKit

class ExpenseTrailTableViewCell: UITableViewCell {


    
    @IBOutlet var lbltime:UILabel!
    @IBOutlet var lblrefrenece:UILabel!
    @IBOutlet var lbltype:UILabel!
    @IBOutlet var lblfrom:UILabel!
    @IBOutlet var lblbalance:UILabel!
    @IBOutlet var lblactioned_by:UILabel!
    @IBOutlet var lblassociated_job:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
