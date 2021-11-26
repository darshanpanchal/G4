//
//  MeasureTableViewCell.swift
//  G4VL
//
//  Created by Foamy iMac7 on 27/09/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

protocol MeasureCellDelegate {
    func updateMeasureValue(value:String, cell : MeasureTableViewCell)
}
class MeasureTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet var txtMeasure : UITextField!
    @IBOutlet var lblUnits : UILabel!
    @IBOutlet var lblDescription : UILabel!
    @IBOutlet var lblTitle : UILabel!
    var indexPath : IndexPath?
    var delegate : MeasureCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        txtMeasure.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.updateMeasureValue(value: textField.text!, cell: self)
    }
    
}
