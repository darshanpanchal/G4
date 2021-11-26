//
//  CallButton.swift
//  G4VL
//
//  Created by Michael Miller on 20/01/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import UIKit

class CallButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        
    }
    
    @objc func tapped() {
        
       let job = AppManager.sharedInstance.currentJob
//            let number = job.customer!.contactTelephone1 ?? job.customer!.contactTelephone2,
//            let url = URL(string: "tel://\(number)") {
//            print(job.pickupAddress?.contactNumber)
//            print(job.dropoffAddress?.contactNumber)
        
            if let keyWindow = UIApplication.shared.keyWindow,let rootViewController = keyWindow.rootViewController{
                let actionSheet = UIAlertController.init(title:nil, message:nil, preferredStyle: .actionSheet)
                
                let pickUpAction = UIAlertAction.init(title: "Pickup : \(job?.pickupAddress?.contactNumber ?? "")", style: .default) { (_ ) in
                        if let pickUpNumber = job?.pickupAddress?.contactNumber?.replacingOccurrences(of:" ", with: "") ,
                             let pickUpURL = URL(string: "tel://\(pickUpNumber)"),pickUpNumber.count > 0{
                                UIApplication.shared.open(pickUpURL, options: [:]) { (finished) in
                                }
                        }
                }
                actionSheet.addAction(pickUpAction)
                let dropAction = UIAlertAction.init(title: "Dropoff : \(job?.dropoffAddress?.contactNumber ?? "")", style: .default) { (_ ) in
                    if let pickUpNumber = job?.dropoffAddress?.contactNumber?.replacingOccurrences(of:" ", with: "") ,
                        let pickUpURL = URL(string: "tel://\(pickUpNumber)"),pickUpNumber.count > 0{
                        UIApplication.shared.open(pickUpURL, options: [:]) { (finished) in
                        }
                    }
                }
                actionSheet.addAction(dropAction)
                var strOfficeMobileNumber = ""
                if let officeNumber = AppManager.sharedInstance.currentUser?.officeNumber{
                    strOfficeMobileNumber = officeNumber
                }
                let officeAction = UIAlertAction.init(title: "Office : \(strOfficeMobileNumber)", style: .default) { (_ ) in
                    let pickUpNumber = strOfficeMobileNumber.replacingOccurrences(of:" ", with: "")
                        if let pickUpURL = URL(string: "tel://\(pickUpNumber)"),pickUpNumber.count > 0{
                            
                        UIApplication.shared.open(pickUpURL, options: [:]) { (finished) in
                            
                        }
                    }
                }
                actionSheet.addAction(officeAction)
                let cancelAction = UIAlertAction.init(title:"Cancel", style: .cancel) { (_ ) in
                    
                }
                actionSheet.addAction(cancelAction)
                if let presenter = actionSheet.popoverPresentationController {
                    presenter.sourceView = self
                    presenter.sourceRect = self.bounds
                }
                rootViewController.present(actionSheet, animated: true, completion: nil)
            }
            /*
            UIApplication.shared.open(url, options: [:]) { (finished) in
                
            }*/
//        }
    }
    
    

}
