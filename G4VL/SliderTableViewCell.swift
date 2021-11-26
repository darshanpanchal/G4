//
//  SliderTableViewCell.swift
//  G4VL
//
//  Created by Foamy iMac7 on 05/01/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

protocol SliderCellDelegate {
    func didUpdateSlider(cell:SliderTableViewCell)
}

class SliderTableViewCell: UITableViewCell {
    
    var delegate : SliderCellDelegate?
    @IBOutlet var slider : UISlider!
    @IBOutlet var valueLabel : UILabel!
    var stepSize : Float = 1
    var indexPath : IndexPath?
    var previousValue : Float?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
    }
    
    @IBAction func sliderDidUpdate(sender:UISlider) {
       
        let roundedValue = round(sender.value / stepSize) * stepSize
        
        slider.value = roundedValue
        valueLabel.text = "\(Int(roundedValue))"
        
        if previousValue == nil || Int(previousValue!) != Int(roundedValue) {
            self.delegate?.didUpdateSlider(cell: self)
            previousValue = roundedValue
        }
        
        
    }

}
