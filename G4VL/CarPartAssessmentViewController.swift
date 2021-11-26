//
//  CarPartAssessmentViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 11/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import CoreData

class CarPartAssessmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PhotoDelegate, SwitchCellDelegate, RadioCellDelegate, NotesDelegate {
   
    
    var appManager = AppManager.sharedInstance
    var vehiclePart : VehiclePart?
    var image : UIImage?
    var index = 0
    var flipped = false
    
    var entry : ManualAppraisalEntry?
    
    var jobAppraisal : JobAppraisal {
        return AppManager.sharedInstance.currentJobAppraisal!
    }
    
    var pickup = true
    @IBOutlet var partLabel:UILabel!
    @IBOutlet var partImageView:UIImageView!
    @IBOutlet var lblPhotoCount : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if pickup {
            entry = jobAppraisal.manualAppraisal!.pickup
        }
        else {
            entry = jobAppraisal.manualAppraisal!.dropoff
        }
        
        vehiclePart = entry!.vehicleParts![index] as VehiclePart
        
        partLabel.text = vehiclePart!.label
        partImageView.image = image
        partImageView.contentMode = .scaleAspectFit
        
        if flipped {
            partImageView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        
       
        if  vehiclePart!.photoNames != nil {
            
            let photoCount = (vehiclePart!.photoNames!).count
            
            if photoCount == 1 {
                lblPhotoCount.text = "\(photoCount) photo added"
            }
            else {
                lblPhotoCount.text = "\(photoCount) photos added"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back() {
        DispatchQueue.main.async(execute: {
            if VehiclePartAnalysis.anyDamagesForPart(vehiclePart: self.vehiclePart!),self.isPhotoAdded() {
                
                self.appManager.damagedParts.appendWithoutDuplication(self.vehiclePart!.name!)
                self.appManager.completedParts.appendWithoutDuplication(self.vehiclePart!.name!)
                self.appManager.progressControl!.updateProgress()
                self.navigationController!.popViewController(animated: true)
            }else{
                let objSimpleAlert = SimpleAlert.dismissAlert(message: "You must add a photo for the damage you have selected", title: "No Photo Added", cancel:"Ok")
                self.present(objSimpleAlert, animated: true, completion: nil)
            }
            
          
        })
       
    }
    
    @IBAction func buttonContinueSelector(){
        DispatchQueue.main.async(execute: {
            if VehiclePartAnalysis.anyDamagesForPart(vehiclePart: self.vehiclePart!),self.isPhotoAdded(){
                self.appManager.damagedParts.appendWithoutDuplication(self.vehiclePart!.name!)
                self.appManager.completedParts.appendWithoutDuplication(self.vehiclePart!.name!)
                self.appManager.progressControl!.updateProgress()
                self.navigationController!.popViewController(animated: true)
            }else{
                //Show Validation alert
                let objSimpleAlert = SimpleAlert.dismissAlert(message: "You must add a photo for the damage you have selected", title: "No Photo Added", cancel:"Ok")
                self.present(objSimpleAlert, animated: true, completion: nil)
                
            }
        })
    }
    func isPhotoAdded()->Bool{
        if let parts = self.vehiclePart,let photoNames = parts.photoNames,photoNames.count > 0{
            return true
        }else{
            return false
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "to_photos_from_parts" {
            
            let vc = segue.destination as! PhotoViewController
            vc.photoDelegate = self
            vc.pickup = pickup
            if vehiclePart!.photoNames != nil {
                vc.photoNames = vehiclePart!.photoNames!
                vc.uploadCareURL = vehiclePart!.uploadCarePhotoNames!
            }
        }

        
    }
    
    
    //MARK: TableView Delegate/Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if vehiclePart!.damages == nil {
            return 0
        }
        
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let damages = vehiclePart!.damages![indexPath.row] as Damage
        
        let identifier = damages.identifier!
        
        if identifier == .notes {
            return 250
        }
        
        return 60
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return vehiclePart!.damages!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let damage = vehiclePart!.damages![indexPath.row]
        
        let identifier = damage.identifier!
        
        
        if identifier == .radio {
            let cell : RadioTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue) as! RadioTableViewCell
            let options = damage.options!
            
            cell.options = options
            
            cell.indexPath = indexPath
            cell.delegate = self
            
            
            if Int(damage.selected!) == 0 {
                cell.selectedOption = ""
            }
            else { 
                cell.selectedOption = options[Int(damage.selected!-1)]
            }
            
            cell.setOptions()
         
            return cell
        }
            
        else if identifier == .identifierSwitch {
            let cell : SwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue) as! SwitchTableViewCell
            
            cell.titleLabel.text = damage.label!
            cell.delegate = self
            cell.sw.isOn = damage.state!
            cell.indexPath = indexPath
            
            
            return cell
        }
        else if identifier == .notes {
            let cell : NotesTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue) as! NotesTableViewCell
            cell.txtNotes.text = damage.text ?? ""
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    //MARK: Cell Delegates
    
    func didToggleSwitch(cell: SwitchTableViewCell) {
        
        var damages = vehiclePart!.damages!
        let damage = vehiclePart!.damages![cell.indexPath!.row]
       
        damage.state = cell.sw.isOn
        
        damages[cell.indexPath!.row] = damage
        
        vehiclePart!.damages = damages
        
        var parts = entry!.vehicleParts!
        
        parts[self.index] = vehiclePart!
        
        entry!.vehicleParts = parts
        
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
        
    }
    
    func didSelectOption(cell: RadioTableViewCell) {
        
        var damages = vehiclePart!.damages!
        let damage = vehiclePart!.damages![cell.indexPath!.row]
        
        let index = (damage.options!).index(of: cell.selectedOption)
        
        damage.selected = Int(index!) + 1
        
        damages[cell.indexPath!.row] = damage
        
        vehiclePart!.damages = damages
        
        var parts = entry!.vehicleParts!
        
        parts[self.index] = vehiclePart!
        
        entry!.vehicleParts = parts
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
        
    }
    
    func updateNotes(value: String, cell: NotesTableViewCell) {
        
        var damages = vehiclePart!.damages!
        let damage = vehiclePart!.damages![cell.indexPath!.row]
        
        damage.text = value
        
        damages[cell.indexPath!.row] = damage
        
        vehiclePart!.damages = damages
        
        var parts = entry!.vehicleParts!
        
        parts[self.index] = vehiclePart!
        
        entry!.vehicleParts = parts
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
        
    }
    
    //MARK: Photo Delegates
    func updatePhotos(photoNames: [String], uploadCare: [String]) {
        if vehiclePart!.photoNames == nil {
            vehiclePart!.photoNames = []
            vehiclePart!.uploadCarePhotoNames = []
        }
        
        vehiclePart!.photoNames = photoNames
        vehiclePart!.uploadCarePhotoNames = uploadCare
        
        var parts = entry!.vehicleParts!
        
        parts[self.index] = vehiclePart!
        
        entry!.vehicleParts = parts
        
        
        if photoNames.count == 1 {
            lblPhotoCount.text = "\(photoNames.count) photo added"
        }
        else {
            lblPhotoCount.text = "\(photoNames.count) photos added"
        }
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
    }
    func updatePhotos(photoNames: [String]) {
        
        if vehiclePart!.photoNames == nil {
            vehiclePart!.photoNames = []
            vehiclePart!.uploadCarePhotoNames = []
        }
        
        vehiclePart!.photoNames = photoNames
        vehiclePart!.uploadCarePhotoNames = photoNames
        
        var parts = entry!.vehicleParts!
        
        parts[self.index] = vehiclePart!
        
        entry!.vehicleParts = parts
        
        
        if photoNames.count == 1 {
            lblPhotoCount.text = "\(photoNames.count) photo added"
        }
        else {
            lblPhotoCount.text = "\(photoNames.count) photos added"
        }
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
        
    }
    
    
    
    

    

}
