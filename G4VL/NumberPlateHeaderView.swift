//
//  NumberPlateHeaderView.swift
//  G4VL
//
//  Created by Michael Miller on 17/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import UIKit

protocol NumberPlateHeaderViewDelegate {
    func tappedHeader()
}

class NumberPlateHeaderView: UICollectionReusableView {
    
    var delegate : NumberPlateHeaderViewDelegate?
    
    @IBOutlet private var lblScanState : UILabel!
    @IBOutlet private var lblReg : UILabel!
    @IBOutlet private var containerView : UIView!

    @IBOutlet var corners: UIView!
    @IBOutlet var nonCorners: [UIView]!
    
    private let blueColor = UIColor(red: 58/255.0, green: 58/255.0, blue: 86/255.0, alpha: 1.0)
    
    
    func setContent(scanLabelString : String, regLabelString:String) {
        lblReg.text = regLabelString.uppercased()
        lblScanState.text = scanLabelString.uppercased()
    }
    
    func invert(_ invert : Bool) {
        
        if invert {
            containerView.backgroundColor = blueColor
            lblReg.textColor = .white
            lblScanState.textColor = .white
            corners.backgroundColor = .white
            for v in nonCorners {
                v.backgroundColor = blueColor
            }
        }
        else {
            containerView.backgroundColor = .white
            lblReg.textColor = blueColor
            lblScanState.textColor = blueColor
            corners.backgroundColor = blueColor
            for v in nonCorners {
                v.backgroundColor = .white
            }
            
        }
        
    }
    
    @IBAction func tappedHeader() {
        delegate?.tappedHeader()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.borderWidth = 4.0
        containerView.layer.borderColor = UIColor(red: 58/255.0, green: 58/255.0, blue: 86/255.0, alpha: 1.0).cgColor
    }
    
}
