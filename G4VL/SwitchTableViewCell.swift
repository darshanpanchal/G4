//
//  SwitchTableViewCell.swift
//  G4VL
//
//  Created by Foamy iMac7 on 11/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

protocol SwitchCellDelegate {
    func didToggleSwitch(cell:SwitchTableViewCell)
}

class SwitchTableViewCell: UITableViewCell  {
    
    var delegate : SwitchCellDelegate?
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var sw : SegmentSwitch!
    var title = ""
   var indexPath : IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        sw.addTarget(self, action: #selector(switchItUp), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
    }
    
    
    @objc func switchItUp() {
        
        
        self.delegate?.didToggleSwitch(cell: self)
    }

}
