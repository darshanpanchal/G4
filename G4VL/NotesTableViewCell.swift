//
//  NotesTableViewCell.swift
//  G4VL
//
//  Created by Foamy iMac7 on 20/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

protocol NotesDelegate {
    func updateNotes(value:String, cell:NotesTableViewCell)
}

class NotesTableViewCell: UITableViewCell, UITextViewDelegate {
    
    var delegate : NotesDelegate?
    @IBOutlet var txtNotes : UITextView!
    var indexPath : IndexPath?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.masksToBounds = true
        txtNotes.delegate = self
        
        self.backgroundColor = UIColor.clear
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.updateNotes(value: textView.text!, cell: self)
    }
    

}
