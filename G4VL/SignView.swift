//
//  SignView.swift
//  G4VL
//
//  Created by Foamy iMac7 on 28/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

protocol SignViewDelegate {
    func didStartSigning()
    func didFinishSigning()
}

class SignView: UIView {

    
    var delegate : SignViewDelegate?
    var touch : UITouch!
    var lineArray : [[CGPoint]] = [[CGPoint]()]
    var index = -1
    var context : CGContext?
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    
    func setup() {
        
        self.isExclusiveTouch = true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.delegate?.didStartSigning()
        touch = touches.first! as UITouch
        let lastPoint = touch.location(in: self)
        
        index += 1
        lineArray.append([CGPoint]())
        lineArray[index].append(lastPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch = touches.first! as UITouch
        let currentPoint = touch.location(in: self)
        
        self.setNeedsDisplay()
        
        lineArray[index].append(currentPoint)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.didFinishSigning()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.didFinishSigning()
    }
    
    override func draw(_ rect: CGRect) {
        
        if(index >= 0){
            context = UIGraphicsGetCurrentContext()
            context!.setLineWidth(5)
            context!.setStrokeColor((UIColor(red:0, green:0, blue:0, alpha:1.0)).cgColor)
            context!.setLineCap(.round)
            
            var j = 0
            while( j <= index ){
                context!.beginPath()
                var i = 0
                context?.move(to: lineArray[j][0])
                while(i < lineArray[j].count){
                    context?.addLine(to: lineArray[j][i])
                    i += 1
                }
                
                context!.strokePath()
                j += 1
                
            }
            
            
        }
        
    }
    
    @IBAction func clear() {
        context = nil;
        lineArray.removeAll()
        index = -1
        setNeedsDisplay()
    }
    
    
//    func imageFromContext() -> UIImage? {
//        if context == nil {
//            return nil
//        }
//        let cgImage = context!.makeImage()
//        return UIImage.init(cgImage: cgImage!)
//    }
    
    func imageFromContext() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }

}
