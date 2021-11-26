//
//  WarningLightsViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 27/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import ImagePicker
import CoreData

class WarningLightsViewController: UIViewController, PhotoDelegate {
    
    var appManager = AppManager.sharedInstance
    
    @IBOutlet var lblPhotoCount : UILabel!
    @IBOutlet var infoDisplay : UIView!
    @IBOutlet var btnConfirm : UIButton!
    @IBOutlet var constraint : NSLayoutConstraint!
    @IBOutlet var switcher : SegmentSwitch!
    @IBOutlet var numberTextView : UITextView!
    
    var jobAppraisal : JobAppraisal {
        return AppManager.sharedInstance.currentJobAppraisal!
    }
    
    var pickup = true
    var entry : WarningLightEntry?
    
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.switcher.addTarget(self, action: #selector(toggleWarningLights), for: .valueChanged)

        numberTextView.text = self.appManager.currentUser!.officeNumber!
        
        if jobAppraisal.warningLight == nil {
            jobAppraisal.warningLight = WarningLight(pickup: nil, dropoff: nil)
        }
        
        if pickup {
            entry = jobAppraisal.warningLight!.pickup
        }else {
            entry = jobAppraisal.warningLight!.dropoff
        }
        guard entry!.photoNames.count > 0 else {
            return
        }
        if entry!.photoNames.count > 0,entry!.photoNames.count == 1{
            lblPhotoCount.text = "\(entry!.photoNames.count) photo added"
        }
        else {
            lblPhotoCount.text = "\(entry!.photoNames.count) photos added"
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            
        if jobAppraisal.warningLight == nil {
            jobAppraisal.warningLight = WarningLight(pickup: nil, dropoff: nil)
        }
        
        if entry!.photoNames.count > 0 {
            switcher.isOn = true
            btnConfirm.isHidden = false
            infoDisplay.isHidden = false
            constraint.constant = 295
        }
        
        
    }
    @IBAction func toggleWarningLights(sw:SegmentSwitch) {
       DispatchQueue.main.async {
            self.infoDisplay.isHidden = !sw.isOn
            if sw.isOn {
                if self.entry!.photoNames.count > 0 {
                    self.btnConfirm.isHidden = false
                }else {
                    self.btnConfirm.isHidden = true
                }
                self.constraint.constant = 295
            }else {
                self.constraint.constant = 20
                self.btnConfirm.isHidden = false
            }
            self.view.layoutIfNeeded()
       }
    
        
    }
    
    
    
    
    @IBAction func confirm() {
        
        entry!.complete = true
        JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
        
        self.back()
        
    }
    
    //MARK: Photo Delegates
    func updatePhotos(photoNames: [String], uploadCare: [String]) {
        entry!.uploadCarePhotoNames = uploadCare
        entry!.photoNames = photoNames
        if photoNames.count > 0{
            if photoNames.count == 1 {
                lblPhotoCount.text = "\(photoNames.count) photo added"
            }
            else {
                lblPhotoCount.text = "\(photoNames.count) photos added"
            }
        }else{
            lblPhotoCount.text = "Add/Edit Image"
        }
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
    }
    func updatePhotos(photoNames: [String]) {
        entry!.uploadCarePhotoNames = photoNames
        entry!.photoNames = photoNames
        if photoNames.count > 0{
            if photoNames.count == 1 {
                lblPhotoCount.text = "\(photoNames.count) photo added"
            }
            else {
                lblPhotoCount.text = "\(photoNames.count) photos added"
            }
        }else{
            lblPhotoCount.text = "Add/Edit Image"
        }
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
    }
    
    //MARK: Navigation
    
    @IBAction func moveToPhotos() {
        self.performSegue(withIdentifier: "to_photos_from_warning_lights", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "to_photos_from_warning_lights" {
            let vc = segue.destination as! PhotoViewController
            vc.photoDelegate = self
            vc.pickup = pickup
            vc.photoNames = entry!.photoNames
            vc.uploadCareURL = entry!.uploadCarePhotoNames ?? []
        }
        
    }


}
