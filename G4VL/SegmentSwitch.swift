//
//  SegmentSwitch.swift
//  G4VL
//
//  Created by Michael Miller on 19/01/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import UIKit

class SegmentSwitch: UISegmentedControl {

   
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        self.removeAllSegments()
        self.tintColor = UIColor(red: 58/255.0, green: 58/255.0, blue: 86/255.0, alpha: 1.0)
        self.insertSegment(withTitle: "Yes", at: 0, animated: false)
        self.insertSegment(withTitle: "No", at: 0, animated: false)
        self.selectedSegmentIndex = 0
        self.addTarget(self, action: #selector(toggle), for: .valueChanged)
    }
    
    var isOn : Bool = false {
        didSet {
           self.selectedSegmentIndex = isOn ? 1 : 0
        }
        
    }
    
    
    @objc private func toggle() {
        
        isOn = self.selectedSegmentIndex == 0 ? false : true
    }
    
}
class SegmentSwitchThree: UISegmentedControl {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        self.removeAllSegments()
        self.tintColor = UIColor(red: 58/255.0, green: 58/255.0, blue: 86/255.0, alpha: 1.0)
        self.insertSegment(withTitle: "Poor", at: 0, animated: false)
        self.insertSegment(withTitle: "Good", at: 0, animated: false)
        self.insertSegment(withTitle: "Very Good", at: 0, animated: false)
        self.selectedSegmentIndex = 0
        self.addTarget(self, action: #selector(toggle), for: .valueChanged)
    }
    
    var isOn : Bool = false {
        didSet {
            self.selectedSegmentIndex = isOn ? 1 : 0
        }
        
    }
    
    
    @objc private func toggle() {
        
        isOn = self.selectedSegmentIndex == 0 ? false : true
    }
    
}
