//
//  InspectionContainer.swift
//  G4VLCarInspection
//
//  Created by Foamy iMac7 on 11/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

protocol InspectionContainerDelegate {
    func didSelectSection(section: VehicleImage)
}

class InspectionContainer: UIView, InspectionViewDelegate, UIScrollViewDelegate {
    let appManager = AppManager.sharedInstance
    let toolbarHeight : CGFloat = 60
    var delegate : InspectionContainerDelegate?
    
    var images  : [[VehicleImage]] = []
    var perspectiveTitles : [String] = []
    
    var theScroller : UIScrollView?
    
    var rootStackView : UIStackView?
    var perspectiveStackview : UIStackView?
    var markAllStackView : UIStackView?
    
    var currentPerspective : UIButton?
    
    var currentImages : [VehicleImage]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        
    }
    
    func setup() {
        
        
        
        let type = appManager.currentJob!.vehicle!.type ?? "".lowercased()
        
        if type == VehicleType.VAN {
            
            perspectiveTitles  = ["Front","Driver Side","Back","Passenger Side","Inside"]
            
            images  = [VehicleSections.getFront(vehicleType: appManager.currentJob!.vehicle!.type ?? ""),
                       VehicleSections.getDriverSide(vehicleType: appManager.currentJob!.vehicle!.type!,slideDoor: (appManager.currentJob!.vehicle!.slidingDoor != nil && appManager.currentJob!.vehicle!.slidingDoor == "driver_side")),
                       VehicleSections.getBack(vehicleType: appManager.currentJob!.vehicle!.type!),
                       VehicleSections.getPassengerSide(vehicleType: appManager.currentJob!.vehicle!.type!,slideDoor: (appManager.currentJob!.vehicle!.slidingDoor != nil && appManager.currentJob!.vehicle!.slidingDoor == "passenger_side")),
                       VehicleSections.getInside(vehicleType: appManager.currentJob!.vehicle!.type!,slideDoor: (appManager.currentJob!.vehicle!.slidingDoor != nil && appManager.currentJob!.vehicle!.slidingDoor == "passenger_side"))
            ]
            
        }
        else {
            
            perspectiveTitles  = ["Front","Driver Side","Back","Passenger Side","Roof","Inside"]
            
            images  = [VehicleSections.getFront(vehicleType: type),
                       VehicleSections.getDriverSide(vehicleType: type, slideDoor: false),
                       VehicleSections.getBack(vehicleType: type),
                       VehicleSections.getPassengerSide(vehicleType: type, slideDoor: false),
                       VehicleSections.getTop(vehicleType: type),
                       VehicleSections.getInside(vehicleType: type, slideDoor: false)
            ]
        }
        
        
        
        for a in images {
            for b in a {
                if b.part != nil {
                    if  !(appManager.partsToComplete.contains(b.part!)) {
                        
                        appManager.partsToComplete.append( b.part!)
                    }
                }
                
            }
        }
        
        
        rootStackView = UIStackView()
        rootStackView?.autoresizingMask = .flexibleWidth
        rootStackView?.alignment = .fill
        rootStackView?.axis = .vertical
        rootStackView?.spacing = 8
        rootStackView?.distribution = .fillEqually
        self.addSubview(rootStackView!)
        
        perspectiveStackview = UIStackView()
        perspectiveStackview?.autoresizingMask = .flexibleWidth
        perspectiveStackview?.alignment = .fill
        perspectiveStackview?.axis = .horizontal
        perspectiveStackview?.spacing = 4
        perspectiveStackview?.distribution = .fillEqually
        rootStackView?.addArrangedSubview(perspectiveStackview!)
        
        var counter = 0
        for _ in images {
            
            //add buttons to tool bar
            let button = UIButton()
            button.tag = counter + 1
            button.alpha = 0.5
            button.backgroundColor = UIColor(red: 58/255.0, green: 58/255.0, blue: 86/255.0, alpha: 1.0)
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitle(perspectiveTitles[counter], for: .normal)
            button.titleLabel?.font = UIFont(name: "JosefinSans-SemiBold", size: 12)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.addTarget(self, action: #selector(InspectionContainer.perspectiveSelected(sender:)), for: .touchUpInside)
            perspectiveStackview?.addArrangedSubview(button)
            
            counter += 1
            
            if currentPerspective == nil {
                
                currentPerspective = button
                button.alpha = 1.0
                
            }
            
        }
        
        
        rootStackView?.frame =  CGRect(x: 0, y: self.frame.size.height-toolbarHeight-8, width: self.frame.size.width, height: toolbarHeight)
        
        
        
        theScroller = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height-toolbarHeight))
        theScroller!.zoomScale = 1
        theScroller!.maximumZoomScale = 4
        theScroller!.minimumZoomScale = 1
        theScroller!.showsHorizontalScrollIndicator = false
        theScroller!.showsVerticalScrollIndicator = false
        theScroller!.bounces = false
        theScroller!.bouncesZoom = false
        theScroller!.delegate = self
        self.addSubview(theScroller!)
        
        
        loadInspectionView(i: 0)
    }
    

    
    func loadInspectionView(i : Int) {
        
        currentImages = self.images[i]
        
        
        for v in self.theScroller!.subviews {
            
            v.removeFromSuperview()
            
        }
        
        
        let inspectionView = InspectionView()
        if self.perspectiveTitles[i] == "Front" || self.perspectiveTitles[i] == "Back" {
            inspectionView.frame = CGRect(x: 0, y: 0, width: self.theScroller!.frame.size.width, height: self.theScroller!.frame.size.height)
        }
        else {
            inspectionView.frame = CGRect(x: 0, y: 0, width: self.theScroller!.frame.size.width, height: self.theScroller!.frame.size.height)
        }
        
        inspectionView.delegate = self
        inspectionView.backgroundColor = UIColor.clear
        inspectionView.vehicleImages = currentImages
        inspectionView.clipsToBounds = true
        
        self.theScroller!.addSubview(inspectionView)
        
        if self.perspectiveTitles[i] == "Driver Side" {
            inspectionView.drawSections(contentMode:.scaleAspectFit, flipped: true)
        }
        else if self.perspectiveTitles[i] == "Passenger Side" || self.perspectiveTitles[i] == "Roof" || self.perspectiveTitles[i] == "Inside" {
            inspectionView.drawSections(contentMode:.scaleAspectFit, flipped: false)
        }
        else {
            inspectionView.drawSections(contentMode:.scaleAspectFit, flipped: false)
        }
        
        
        
        updateView()
        
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
    
    
    
    func updateView() {
        guard let _ = self.currentImages else {
            return
        }
        DispatchQueue.global().async {
            for vehicalImage in self.currentImages! {
                
                if vehicalImage.part == nil {
                    continue
                }
                if vehicalImage.imageViewReference == nil {
                    continue
                }
                
                
                if self.appManager.damagedParts.contains(vehicalImage.part!) {
                    if vehicalImage.imageViewReference != nil {
                        DispatchQueue.main.sync {
                            vehicalImage.imageViewReference!.image = UIImage(named:"\(vehicalImage.mainImage!)_damaged")
                        }
                        
                    }
                }
                else if self.appManager.completedParts.contains(vehicalImage.part!) {
                    
                    if vehicalImage.imageViewReference != nil {
                        DispatchQueue.main.sync {
                            vehicalImage.imageViewReference!.image = vehicalImage.originalImage!
                           // vehicalImage.imageViewReference!.image = UIImage(named:"\(vehicalImage.mainImage!)_good")
                        }
                        
                    }
                }
                else if self.appManager.partsToComplete.contains(vehicalImage.part!) {
                    if vehicalImage.imageViewReference != nil {
                        DispatchQueue.main.sync {
                            vehicalImage.imageViewReference!.image = vehicalImage.originalImage!
                        }
                        
                    }
                }
                
                
            }
        }
        
        appManager.progressControl!.updateProgress()
        
    }
    
    
    func didSelectSection(carImage: VehicleImage) {
        delegate?.didSelectSection(section: carImage)
    }
    
    @objc func perspectiveSelected(sender : UIButton) {
        
        
        self.loadInspectionView(i: sender.tag-1)
        self.currentPerspective?.alpha = 0.5
        self.currentPerspective = sender
        self.currentPerspective?.alpha = 1.0
        
        self.theScroller?.zoomScale = 1
        
        
        
        
    }
    
    
    
    
}

