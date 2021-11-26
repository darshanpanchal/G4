//
//  AssessmentProgressControl.swift
//  G4VL
//
//  Created by Foamy iMac7 on 26/10/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit


class AssessmentProgressControl: UIControl {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let appManager = AppManager.sharedInstance
    var progressBar : UIView!
    @IBOutlet var progressBarOutline : UIView!
    @IBOutlet var progressLabel : UILabel!
    @IBOutlet var completeButton : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func updateProgress() {
        
        
        
//        let current = appManager.completedParts.count + appManager.completedSections.count
//        let total = appManager.partsToComplete.count + appManager.sectionsToComplete.count
        
        let current = appManager.completedSections.count
        let total =  appManager.sectionsToComplete.count
        
        
        
        progressLabel.text = "\(current) / \(total) complete"
        
        let percentageDecimal : CGFloat = (CGFloat(current) / CGFloat(total))
        
        
        var width = progressBarOutline.frame.size.width * CGFloat(percentageDecimal)
        
        width = min(progressBarOutline.frame.size.width, width)
        
        if progressBar == nil {
            progressBar = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 4))
            progressBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            progressBar.backgroundColor = completeButton.backgroundColor
            progressBar.translatesAutoresizingMaskIntoConstraints = true
            progressBarOutline.addSubview(progressBar)
        }
        
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.progressBar.frame = CGRect(x: 0, y: 0, width: width, height: 4)
            
            }) { (finished) in
                
                if current >= total {
                    
                    self.completeButton.isHidden = false
                }
                else {
                    
                    self.completeButton.isHidden = true
                }
        }
        
    }
    
    
    @IBAction func showRemaining() {
        
        var remaining : [String] = []
        
//        for part in appManager.partsToComplete {
//
//            if !AppManager.sharedInstance.completedParts.contains(part) {
//                remaining.append(VehicleSections.readibleCarParts(part: part))
//            }
//
//        }
//
        for sect in appManager.sectionsToComplete {
            
            if !AppManager.sharedInstance.completedSections.contains(sect) {
                
                remaining.append(VehicleSections.readibleCarParts(part: sect))
                
            }
            
        }
        
        
        let remainingPartsString = remaining.joined(separator: "\n")
        
        let alert = UIAlertController(title: "Remaining", message: "Please complete the following:\n\n\(remainingPartsString)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        DispatchQueue.main.async {
            let vc = AppManager.sharedInstance.getTopViewController()
            vc.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
}
extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension Array where Element == String {
    
    mutating func appendWithoutDuplication(_ newElement:String) {
        
        let index = self.index(of:newElement)
        
        if index == nil {
            self.append(newElement)
        }
        
    }
    
    mutating func remove(_ element:String) {
        
        let index = self.index(of:element)
        
        if index != nil {
            self.remove(at: index!)
        }
        
    }
}
