//
//  RadioTableViewCell.swift
//  G4VL
//
//  Created by Foamy iMac7 on 10/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

protocol RadioCellDelegate {
    func didSelectOption(cell:RadioTableViewCell)
}

class RadioTableViewCell: UITableViewCell {
    
    var delegate : RadioCellDelegate?
    @IBOutlet var stackView : UIStackView!
    var options : [String]?
    var selectedOption : String = ""
    var title = ""
    var indexPath : IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
    func setOptions() {
        
        for v in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        
        for option in options! {
            
           
            
            let button = UIButton()
            button.setTitle(option, for: .normal)
            
            if selectedOption == option {
                button.backgroundColor = UIColor(red: 58/255.0, green: 58/255.0, blue: 86/255.0, alpha: 1.0)
                button.setTitleColor(UIColor.white, for: .normal)
            }
            else {
                button.backgroundColor = UIColor.white
                button.setTitleColor(UIColor.black, for: .normal)
            }
            
            
            
            button.titleLabel?.font = UIFont(name: "JosefinSans-SemiBold", size: 13)
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.cornerRadius = stackView.frame.size.height/2
            button.layer.masksToBounds = true
            button.addTarget(self, action: #selector(RadioTableViewCell.selectOption), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            
            
        }
        
    }
    
    @objc func selectOption(button:UIButton) {
        
        selectedOption = button.title(for: .normal)!
        
        setOptions()
        
        self.delegate?.didSelectOption(cell: self)
        
    }
    
}
