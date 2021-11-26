//
//  MessageHeaderView.swift
//  G4VL
//
//  Created by Michael Miller on 16/05/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

protocol MessageHeaderViewDelegate {
    func viewAll(section:Int)
}

class MessageHeaderView: UITableViewHeaderFooterView {
    
    var delegate : MessageHeaderViewDelegate?
    var section:Int = 0
    @IBOutlet var topLabel : UILabel!
    @IBOutlet var bottomLabel : UILabel!
    
    @IBAction func viewAll() {
        self.delegate?.viewAll(section: section)
    }

}
