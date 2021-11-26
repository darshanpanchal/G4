//
//  FleetViewController.swift
//  G4VL
//
//  Created by Michael Miller on 04/04/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

class FleetViewController: UIViewController, PhotoDelegate {
    
    var appManager = AppManager.sharedInstance
    
    @IBOutlet var lblPhotoCount : UILabel!
    
    @IBOutlet var btnConfirm : UIButton!
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if appManager.currentJobAppraisal?.paperwork == nil {
            appManager.currentJobAppraisal!.paperwork = Paperwork(photoNames: nil)
        }
        
        
        if appManager.currentJobAppraisal!.paperwork?.photoNames.count == 1 {
            lblPhotoCount.text = "\(appManager.currentJobAppraisal!.paperwork!.photoNames.count) photo added"
            
        }
        else {
            lblPhotoCount.text = "\(appManager.currentJobAppraisal!.paperwork!.photoNames.count) photos added"
        }
        
        btnConfirm.isHidden = appManager.currentJobAppraisal!.paperwork!.photoNames.count == 0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: Photo Delegates
    func updatePhotos(photoNames: [String], uploadCare: [String]) {
        appManager.currentJobAppraisal!.paperwork!.photoNames = photoNames
        appManager.currentJobAppraisal!.paperwork!.uploadCarePhotoNames = uploadCare
        if photoNames.count == 1 {
            lblPhotoCount.text = "\(photoNames.count) photo added"
        }
        else {
            lblPhotoCount.text = "\(photoNames.count) photos added"
        }
        
        JobsManager.saveJobAppraisal(job: appManager.currentJobAppraisal!, saveExpenses: false)
        
        btnConfirm.isHidden = appManager.currentJobAppraisal!.paperwork!.photoNames.count == 0
    }
    func updatePhotos(photoNames: [String]) {
        
        appManager.currentJobAppraisal!.paperwork!.photoNames = photoNames
        
        if photoNames.count == 1 {
            lblPhotoCount.text = "\(photoNames.count) photo added"
        }
        else {
            lblPhotoCount.text = "\(photoNames.count) photos added"
        }
        
        JobsManager.saveJobAppraisal(job: appManager.currentJobAppraisal!, saveExpenses: false)
        
        btnConfirm.isHidden = appManager.currentJobAppraisal!.paperwork!.photoNames.count == 0
    }
    
    @IBAction func confirm() {
        
        appManager.currentJobAppraisal!.paperwork!.complete = true
        
        JobsManager.saveJobAppraisal(job: self.appManager.currentJobAppraisal!, saveExpenses: false)
        
        self.back()
        
    }
    
    //MARK: Navigation
    
    @IBAction func moveToPhotos() {
        self.performSegue(withIdentifier: "to_photos_from_fleet", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "to_photos_from_fleet" {
            let vc = segue.destination as! PhotoViewController
            vc.photoDelegate = self
            vc.pickup = false
            vc.photoNames = appManager.currentJobAppraisal!.paperwork!.photoNames
            vc.uploadCareURL = appManager.currentJobAppraisal!.paperwork!.uploadCarePhotoNames ?? []
        }
        
    }

}
