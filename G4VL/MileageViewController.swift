//
//  MileageViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 27/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import ImagePicker
import CoreData


class MileageViewController: UIViewController, UITextFieldDelegate, PhotoDelegate {
    
    var appManager = AppManager.sharedInstance
   
    @IBOutlet var txtMileage : UITextField!
    @IBOutlet var lblPhotoCount : UILabel!
    
    var jobAppraisal : JobAppraisal {
        return AppManager.sharedInstance.currentJobAppraisal!
    }
    
    var pickup = true
    var entry : MileagePetrolEntry?
    
    
    
    @IBOutlet var btnConfirm : UIButton!
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if jobAppraisal.mileage == nil {
            jobAppraisal.mileage = Mileage(label: "Mileage")
        }
        
        if pickup {
            entry = jobAppraisal.mileage!.pickup
        }
        else {
            entry = jobAppraisal.mileage!.dropoff
        }
        

        let photoCount = entry!.photoNames.count
        if photoCount == 1 {
            lblPhotoCount.text = "\(photoCount) photo added"
        }
        else {
            lblPhotoCount.text = "\(photoCount) photos added"
        }
        
        txtMileage.text = entry!.manualEntry
        
        
        
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func didChangeText() {
        if txtMileage.text!.count > 0 && entry!.photoNames.count > 0 {
            btnConfirm.isHidden = false
        }
        else {
            btnConfirm.isHidden = true
        }
    }
    
    //MARK: Photo Delegates
    func updatePhotos(photoNames: [String], uploadCare: [String]) {
        entry!.uploadCarePhotoNames = uploadCare
        entry!.photoNames = photoNames
        if photoNames.count == 1 {
            lblPhotoCount.text = "\(photoNames.count) photo added"
        }
        else {
            lblPhotoCount.text = "\(photoNames.count) photos added"
        }
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
        
        if photoNames.count > 0 && txtMileage.text!.trimmingCharacters(in: .whitespaces).count > 0 {
            btnConfirm.isHidden = false
        }else {
            btnConfirm.isHidden = true
        }
    }
    func updatePhotos(photoNames: [String]) {
        entry!.uploadCarePhotoNames = photoNames
        entry!.photoNames = photoNames
        if photoNames.count == 1 {
            lblPhotoCount.text = "\(photoNames.count) photo added"
        }
        else {
            lblPhotoCount.text = "\(photoNames.count) photos added"
        }
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
        
        if photoNames.count > 0 && txtMileage.text!.trimmingCharacters(in: .whitespaces).count > 0 {
            btnConfirm.isHidden = false
        }
        else {
            btnConfirm.isHidden = true
        }
    }
    
    
    @IBAction func confirm() {
        
        entry!.manualEntry =  txtMileage.text!
        entry!.complete = true
        JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
        
        self.back()
        
        
    }
    
    //MARK: Navigation
    
    @IBAction func moveToPhotos() {
        self.performSegue(withIdentifier: "to_photos_from_mileage", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "to_photos_from_mileage" {
            let vc = segue.destination as! PhotoViewController
            vc.photoDelegate = self
            vc.pickup = pickup
            vc.photoNames = entry!.photoNames
            vc.uploadCareURL = entry!.uploadCarePhotoNames!
            
        }
        
    }

    
}
