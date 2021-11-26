//
//  PetrolViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 27/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import ImagePicker


class PetrolViewController: UIViewController, PhotoDelegate {
    

    var appManager = AppManager.sharedInstance
    
    @IBOutlet var fuelSlider : UISlider!
    @IBOutlet var lblPhotoCount : UILabel!
    
    @IBOutlet var btnConfirm : UIButton!
    
    var jobAppraisal : JobAppraisal {
        return AppManager.sharedInstance.currentJobAppraisal!
    }
    
    var currentJOB:Job{
        return AppManager.sharedInstance.currentJob!
    }
    var pickup = true
    var entry : MileagePetrolEntry?
    
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if jobAppraisal.petrolLevel == nil {
            jobAppraisal.petrolLevel = PetrolLevel(label: "Petrol Level")
        }
        
        if pickup {
            entry = jobAppraisal.petrolLevel!.pickup
        }
        else {
            entry = jobAppraisal.petrolLevel!.dropoff
        }
        
        let photoCount = entry!.photoNames.count
        
        if photoCount == 1 {
            lblPhotoCount.text = "\(photoCount) photo added"
        }
        else {
            lblPhotoCount.text = "\(photoCount) photos added"
        }
            
        fuelSlider.value = Float(entry!.manualEntry) ?? 0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        
        let roundedValue = round(sender.value / 12.5) * 12.5
        
        sender.value = roundedValue
        
        if entry!.photoNames.count > 0{//,sender.value > 0{
            btnConfirm.isHidden = false
        }else{
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
        
        if photoNames.count > 0{//,fuelSlider.value > 0{
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
        
        if photoNames.count > 0{//,fuelSlider.value > 0{
            btnConfirm.isHidden = false
        }else {
            btnConfirm.isHidden = true
        }
    }
    
    @IBAction func confirm() {
        if let minimumFuel = currentJOB.minimumFuel,!pickup{
            if Int16(fuelSlider.value) < minimumFuel{
                self.showAlertForLowFuel()
                return
            }
        }
        self.confirmFinal()
    }
    func showAlertForLowFuel(){
        let objAlert = UIAlertController.init(title: "Alert", message: "Not enough fuel as per instruction", preferredStyle: .alert)
        let okayAction = UIAlertAction.init(title: "Ok", style: .cancel) { (_ ) in
            self.confirmFinal()
        }
        objAlert.addAction(okayAction)
        let roundedValue = round(fuelSlider.value / 12.5) * 12.5
        print(roundedValue)
        
        print("\(Int16(fuelSlider.value))")
        
        self.present(objAlert, animated:true, completion: nil)
    }
    func confirmFinal(){
         if jobAppraisal.petrolLevel == nil {
         jobAppraisal.petrolLevel = PetrolLevel(label: "Petrol Level")
         }
         let roundedValue = round(fuelSlider.value / 12.5) * 12.5
         print(roundedValue)
        
         entry!.manualEntry = "\(roundedValue)"// "\(Int16(fuelSlider.value))"
         entry!.complete = true
         
         JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
         self.back()
        
    }
    
    //MARK: Navigation
    
    @IBAction func moveToPhotos() {
        self.performSegue(withIdentifier: "to_photos_from_petrol", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "to_photos_from_petrol" {
            let vc = segue.destination as! PhotoViewController
            vc.photoDelegate = self
            vc.pickup = pickup
            vc.photoNames = entry!.photoNames
            vc.uploadCareURL = entry!.uploadCarePhotoNames!
            
        }
        
    }

}
