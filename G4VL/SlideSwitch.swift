//
//  SlideSwitch.swift
//  G4VL
//
//  Created by Foamy iMac7 on 26/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

protocol SlideSwitchDelegate {
    func slid()
}

class SlideSwitch: UIView {
    
    var delegate : SlideSwitchDelegate?
    @IBOutlet var slide : UIImageView!
    @IBOutlet var track : UIView!
    var lockedIn = false
    @IBOutlet var coverLabel : UIView!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    
    func setup() {
        
        
    }
    
    func reset() {
        self.slide.center = CGPoint(x: self.slide.frame.size.width/2, y:self.track.frame.size.height/2)
        self.coverLabel.frame = CGRect(x: 0, y: 0, width: self.slide.center.x, height: self.track.frame.size.height)
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesMoved")
        let touch = touches.first!
        if touch.view == slide {
            
            let location = touch.location(in: track!)
            slide.center = CGPoint(x: location.x, y: track.frame.size.height/2)
            
            if slide.frame.origin.x <= 0 {
                
                slide.center = CGPoint(x:slide.frame.width/2, y:slide.center.y)
                
            }
            
            if slide.frame.origin.x >= track.frame.size.width - slide.frame.size.width {
                
                slide.center = CGPoint(x:track.frame.size.width - slide.frame.width/2, y:slide.center.y)
                lockedIn = true
                coverLabel.frame = CGRect(x: 0, y: 0, width: slide.center.x, height: track.frame.size.height)
                return
            }
            
            coverLabel.frame = CGRect(x: 0, y: 0, width: slide.center.x, height: track.frame.size.height)
            lockedIn = false
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        if touch.view == slide {
           
            if !lockedIn {
                
                slide.isUserInteractionEnabled = false
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.slide.center = CGPoint(x: self.slide.frame.size.width/2, y:self.track.frame.size.height/2)
                    self.coverLabel.frame = CGRect(x: 0, y: 0, width: self.slide.center.x, height: self.track.frame.size.height)
                    
                }, completion: {
                    finished in
                    
                    
                    
                    self.slide.isUserInteractionEnabled = true
                    
                })
                
            }else {
                self.delegate?.slid()
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

}
