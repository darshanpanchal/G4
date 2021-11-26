//
//  MessageCell.swift
//  G4VL
//
//  Created by Foamy iMac7 on 06/09/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet var messageLabel : UILabel!
    @IBOutlet var dateLabel : UILabel!
    @IBOutlet var senderLabel : UILabel!
    private(set) var read : Bool = false
    
    func setRead(read:Bool) {
        self.read = read
        if read {
            self.backgroundColor = .white
        }
        else {
            self.backgroundColor = UIColor(red: 1, green: 1, blue: 204/255.0, alpha: 1.0)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
