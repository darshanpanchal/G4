//
//  InspectionView.swift
//  G4VLCarInspection
//
//  Created by Foamy iMac7 on 10/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import Foundation


protocol InspectionViewDelegate {
    func didSelectSection(carImage:VehicleImage)
}

class InspectionView: UIView {

    var appManager = AppManager.sharedInstance
    var vehicleImages : [VehicleImage]?
    var delegate : InspectionViewDelegate?
    var checkingTouch = false
    var imageViews : [UIImageView]?
    var currentSelectedSection : VehicleImage?
    var reversed = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        
        setup()
    }
    
    func setup() {
        self.isMultipleTouchEnabled = false
        self.isUserInteractionEnabled = true
    }
    
    
    func drawSections(contentMode:UIView.ContentMode, flipped:Bool) {
        
        reversed = flipped
     
        //remove any previous views
        for v in self.subviews {
            v.removeFromSuperview()
        }
        
        imageViews = []
        
        
        if vehicleImages == nil {
            return
        }
        
        for i in 0..<vehicleImages!.count {
            
            let vehicleImage = vehicleImages![i]
            
            let imageview = UIImageView(frame:CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
            //print(vehicleImage.imageTitle!)
            imageview.image = UIImage(named:vehicleImage.mainImage!)!
            
            vehicleImage.originalImage = imageview.image!
            
            imageview.contentMode = contentMode
            vehicleImage.imageViewReference = imageview
            self.addSubview(imageview)
            
            if reversed {
                imageview.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
            
            self.sendSubviewToBack(imageview)
            
            imageViews?.append(imageview)
            
        }
        
        
        
    }


    

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /*
            Gets touch of user and loops through the sections to detect
            which has pixel color at this point.
 
        */
        
        if vehicleImages == nil {
            return
        }
        
        print(touches)
         print( print(touches))
       let touch = touches.first
        
        
        for i in 0..<vehicleImages!.count {
            let vehicleImage = vehicleImages![i]
            let imageView = imageViews![i]
            let location = touch!.location(in: imageView)
            if reversed {
                let reversedLocation = CGPoint(x:location.x, y: location.y)
                if imageView.pixelHasAlpha(point:reversedLocation) {
                    currentSelectedSection = vehicleImage
                    self.delegate?.didSelectSection(carImage:currentSelectedSection!)
                    
                    break;
                }
            }
            else {
                if imageView.pixelHasAlpha(point:location) {
                    currentSelectedSection = vehicleImage
                    self.delegate?.didSelectSection(carImage:currentSelectedSection!)
                    
                    break;
                }
            }
            
            
            
            
        }
        
        
        
    }
    
    
    
    
}

extension UIImageView {
    func pixelHasAlpha(point:CGPoint) -> Bool{
        
//        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
//        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
//
//        context!.translateBy(x: -point.x, y: -point.y)
//
//        layer.render(in: context!)
//
//        let alpha = CGFloat(pixel[3])/255.0
//
//        pixel.deallocate(capacity: 4)
//
//        return alpha > 0.1
        
        if (!self.isHidden && self.getPixelColor(atPosition: point).cgColor.alpha != 0) {return true}
        else {return false}
    }
    
    func getPixelColor(atPosition:CGPoint) -> UIColor{
        
        var pixel:[CUnsignedChar] = [0, 0, 0, 0];
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let bitmapInfo = CGBitmapInfo(rawValue:    CGImageAlphaInfo.premultipliedLast.rawValue);
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue);
        
        context!.translateBy(x: -atPosition.x, y: -atPosition.y);
        layer.render(in: context!);
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                    green: CGFloat(pixel[1])/255.0,
                                    blue: CGFloat(pixel[2])/255.0,
                                    alpha: CGFloat(pixel[3])/255.0);
        
        return color;
        
    }
}

extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    /*
    func overlayWithMask(color:UIColor) -> UIImage? {
        
        let overlay = self.maskWithColor(color: color)
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        self.draw(in: CGRect(x:0.0, y:0.0, width:self.size.width, height:self.size.height))
        overlay!.draw(in: CGRect(x:0.0, y:0.0, width:self.size.width, height:self.size.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        
        
        return self.maskWithColor(color: color)
    }
    */
}
