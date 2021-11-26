//
//  SignatureViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 28/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol SignDelegate {
   func confirmSignature(image: UIImage,model:[String],telepod:[String],paperwork:[String],iscaptureImage:Bool)
}

class SignatureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SignViewDelegate {
    
    
    
    enum Sections : Int {
        case intro = 0
        case info = 1
        case conditionAndContents = 2
        case damages = 3
    }
    
    var jobAppraisal : JobAppraisal {
        return AppManager.sharedInstance.currentJobAppraisal!
    }
    
    var pickup = true
    var isAlertShown = false
    var manualAppraisalEntry : ManualAppraisalEntry?
    
    var delegate : SignDelegate?
    var showAppraisal = false
    
    var conditionAndContents : [(String,String)] = []
    var vehicleInfo : [(String,String)] = []
    var damages : [(String,String)] = []
    
    @IBOutlet var theTable : UITableView!
    
    @IBOutlet var blurContainerView:UIView!
    
    @IBOutlet var subContainerView:UIView!
    
    @IBOutlet var segmentModel:UISegmentedControl!
    @IBOutlet var segmentTelepod:UISegmentedControl!
    @IBOutlet var segmentPaperWork:UISegmentedControl!
    
    var signView : SignView!
    
    var entry : SignatureEntry?
    var captureImageOfVehicleReceiver:UIImage?
    
    lazy var objImagePickerController = UIImagePickerController()
    
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpAlert()
        // Do any additional setup after loading the view.
        
        if pickup {
            manualAppraisalEntry = jobAppraisal.manualAppraisal!.pickup
        }else{
            manualAppraisalEntry = jobAppraisal.manualAppraisal!.dropoff
        }
        if let _ = self.entry{
            //print(self.entry!.signatureFileName)
        }
        theTable.rowHeight = UITableView.automaticDimension
        theTable.estimatedRowHeight = 50
        
        vehicleInfo = [
            ("Vehicle Type",AppManager.sharedInstance.currentJob!.vehicle!.type ?? ""),
            ("Make",AppManager.sharedInstance.currentJob!.vehicle!.make ?? ""),
            ("Model",AppManager.sharedInstance.currentJob!.vehicle!.model ?? ""),
            ("Colour",AppManager.sharedInstance.currentJob!.vehicle!.colour ?? "")
        ]
        
        
        if AppManager.sharedInstance.currentJob!.manualAppraisalRequired == 1 {
            
            let manualAppraisal = AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal!
            
            for vp in manualAppraisal.pickup.vehicleParts! {
                var isDamaged = false
                var damageText = "Damages: "
                
                for damage in vp.damages! {
                    if damage.state != nil && damage.state! {
                        isDamaged = true
                        damageText += "\(damage.label ?? damage.text ?? "") "
                    }
                }
                
                if vp.notes != nil && vp.notes!.count > 0 {
                    isDamaged = true
                    damageText += "Notes:\n\(vp.notes ?? "")"
                }
                
                if isDamaged {
                    self.damages.append((vp.label!.uppercased(),damageText))
                }
            }
            
            
            for section in manualAppraisalEntry!.vehicleDetailSections! {
                
                for row in section.vehicleDetailRows! {
                    
                    var value = ""
                    var label = ""
                    
                    if row.identifier! == .radio {
                        label = row.label ?? ""
                        if row.options != nil && row.selected != nil {
                            value = row.options![row.selected!-1]
                        }
                    }
                    else if row.identifier! == .identifierSwitch {
                        label = row.label ?? ""
                        value = row.state! ? "Yes" : "No"
                    }
                    else if row.identifier! == .slider {
                        label = row.label ?? ""
                        value = "\(Int(row.value))"
                    }
                    
                    if value.count > 0 && label.count > 0 {
                        conditionAndContents.append((label, value))
                    }
                }
            }
                   
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func setUpAlert(){
        self.subContainerView.clipsToBounds = true
        self.subContainerView.layer.cornerRadius = 6.0
        self.segmentModel.selectedSegmentIndex = 0
        self.segmentTelepod.selectedSegmentIndex = 0
        self.segmentPaperWork.selectedSegmentIndex = 0
        
    }
    

    func confirm() {
        
        if self.signView.lineArray.count >= 1,let arrayOfPoint =  self.signView.lineArray.first,arrayOfPoint.count > 0{
            
            if !pickup,!isAlertShown{ //drop off appraisal
                    self.blurContainerView.isHidden = false
                    return
            }else{
                    self.blurContainerView.isHidden = true
            }
           
                
                let image = signView.imageFromContext()
                if image == nil {
                    return;
                }
            delegate?.confirmSignature(image: image!, model: (self.segmentModel.selectedSegmentIndex == 0) ? ["No"] : ["Yes"], telepod: (self.segmentTelepod.selectedSegmentIndex == 0) ? ["No"] : ["Yes"], paperwork:(self.segmentPaperWork.selectedSegmentIndex == 0) ? ["No"] : ["Yes"],iscaptureImage:false)
                //delegate?.confirmSignature(image: image!)
                self.navigationController?.popViewController(animated: true)
        }else{
            if let image = self.captureImageOfVehicleReceiver{
                if !pickup,!isAlertShown{ //drop off appraisal
                        self.blurContainerView.isHidden = false
                        return
                }else{
                        self.blurContainerView.isHidden = true
                }
                delegate?.confirmSignature(image: image, model: (self.segmentModel.selectedSegmentIndex == 0) ? ["No"] : ["Yes"], telepod: (self.segmentTelepod.selectedSegmentIndex == 0) ? ["No"] : ["Yes"], paperwork:(self.segmentPaperWork.selectedSegmentIndex == 0) ? ["No"] : ["Yes"],iscaptureImage:true)
                               
                self.navigationController?.popViewController(animated: true)
                
            }else { //no signature as well as no image capture so below message will popup for validation
                DispatchQueue.main.async {
                    if self.pickup{
                        self.view.makeToast("Please add a signature.")
                    }else{
                        self.view.makeToast("Please add a signature or capture image of vehicle receiver.")
                    }
                            
                }
            }
        }
    }
    
    func clear() {
        
        signView.clear()
    }
    
    @IBAction func buttonAlertOkaySelector(sender:UIButton){
        self.isAlertShown = true
        self.blurContainerView.isHidden = true
    }
    @IBAction func buttonAlertCancleSelector(sender:UIButton){
       
        self.isAlertShown = false
        self.blurContainerView.isHidden = true
    }
    //MARK: UItableview Delegate/Datasource
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if showAppraisal {
            return 5
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if showAppraisal {
            if section == Sections.conditionAndContents.rawValue {
                return conditionAndContents.count
            }
            if section == Sections.info.rawValue {
                return vehicleInfo.count
            }
            if section == Sections.damages.rawValue {
                return damages.count == 0 ? 1 : damages.count
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if showAppraisal {
            if indexPath.section == Sections.intro.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DamagesTableViewCell
                cell.titleLabel.text = ""
                cell.descritptionLabel.text = "By signing this form you agree that all of the information below is accurate at the time of signing.\n\nPlease take your time and request that the driver make any changes if needed. Thank you."
                return cell
            }
            else if indexPath.section == Sections.conditionAndContents.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DamagesTableViewCell
                cell.titleLabel.text = conditionAndContents[indexPath.row].0
                cell.descritptionLabel.text = conditionAndContents[indexPath.row].1
                return cell
            }
            else if indexPath.section == Sections.info.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DamagesTableViewCell
                cell.titleLabel.text = vehicleInfo[indexPath.row].0
                cell.descritptionLabel.text = vehicleInfo[indexPath.row].1
                return cell
            }
            else if indexPath.section == Sections.damages.rawValue {
                
                if damages.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DamagesTableViewCell
                    cell.titleLabel.text = ""
                    cell.descritptionLabel.text = "No damage to the vehicle"
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DamagesTableViewCell
                    cell.titleLabel.text = damages[indexPath.row].0
                    cell.descritptionLabel.text = damages[indexPath.row].1
                    return cell
                }
                
                
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sign_cell") as! SignatureTableViewCell
                signView = cell.signView
                signView.delegate = self
                cell.delegate = self
                cell.imageUploadContainerView.isHidden = self.pickup
                if let objImage = self.captureImageOfVehicleReceiver{
                    cell.imageViewVehicle.image = objImage
                }
                return cell
            }
            
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sign_cell") as! SignatureTableViewCell
            signView = cell.signView
            cell.delegate = self
            cell.imageUploadContainerView.isHidden = self.pickup
            if let objImage = self.captureImageOfVehicleReceiver{
                cell.imageViewVehicle.image = objImage
            }
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        view.backgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
        
        let lbl = UILabel(frame: CGRect(x: 8, y: 10, width: tableView.frame.size.width-16, height: 20))
        lbl.backgroundColor = UIColor.clear
        lbl.font = UIFont(name: "JosefinSans-Bold", size: 18)
        
        if !showAppraisal {
            lbl.text = ""
        }
        else if section == Sections.intro.rawValue {
            lbl.text = "PLEASE NOTE:"
        }
        else if section == Sections.info.rawValue {
            lbl.text = "VEHICLE INFO"
        }
        else if section == Sections.conditionAndContents.rawValue {
            lbl.text = "CONDITION AND CONTENTS"
        }
        else if section == Sections.damages.rawValue {
            lbl.text = "DAMAGES"
        }
        
        
        view.addSubview(lbl)
        
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func didStartSigning() {
        theTable.isScrollEnabled = false
    }
    
    func didFinishSigning() {
        theTable.isScrollEnabled = true
    }
    
}
extension SignatureViewController:SignatureTableViewCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
     func buttonImagePickerSelector(tag: Int) {
         self.presentImagePickerWithTagFromDelegate(tag: tag)
     }
    func presentImagePickerController(tag:Int){
        self.view.endEditing(true)
        self.present(self.objImagePickerController, animated: true, completion: nil)
    }
    func presentImagePickerWithTagFromDelegate(tag:Int){
        let actionSheetController = UIAlertController.init(title: "Take a photo", message:"of the person receiving the vehicle", preferredStyle: .actionSheet)
                       let cancelSelector = UIAlertAction.init(title: "Cancel", style: .cancel, handler:nil)
                       actionSheetController.addAction(cancelSelector)
                       
                       let cameraSelector = UIAlertAction.init(title: "Camera", style: .default) { (_) in

                           DispatchQueue.main.async {
                               self.objImagePickerController = UIImagePickerController()
                               self.objImagePickerController.sourceType = .camera
                               self.objImagePickerController.delegate = self
                               self.objImagePickerController.allowsEditing = false
                               self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                               self.view.endEditing(true)
                               self.presentImagePickerController(tag: tag) // tag 1 for arraival and 2 for completion
                           }
                       }
                       actionSheetController.addAction(cameraSelector)
                       
                       let photosSelector = UIAlertAction.init(title: "Photos", style: .default) { (_) in
                           DispatchQueue.main.async {
                                self.objImagePickerController = UIImagePickerController()
                                self.objImagePickerController.sourceType = .savedPhotosAlbum
                                self.objImagePickerController.delegate = self
                                self.objImagePickerController.allowsEditing = false
                                self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                                self.view.endEditing(true)
                                self.presentImagePickerController(tag: tag) // tag 1 for arraival and 2 for completion
                               
                           }
                       }
                        if UIDevice.current.isSimulator{
                            actionSheetController.addAction(photosSelector)
                        }
                       self.view.endEditing(true)
                       if let popoverController = actionSheetController.popoverPresentationController {
                          let objIndexpath = IndexPath.init(row: tag, section: 0)
                          if let objCell = self.theTable.cellForRow(at: objIndexpath) as? AppraisalTableViewCell{
                            popoverController.sourceRect = objCell.buttonImageVehicle.bounds
                            popoverController.sourceView = objCell.buttonImageVehicle
                          }
                       }
                       self.present(actionSheetController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         
         guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
             
             guard let editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                 dismiss(animated: true, completion: nil)
                 return
             }
            
             dismiss(animated: true, completion: nil)
             return
         }
  
        self.captureImageOfVehicleReceiver = originalImage
        DispatchQueue.main.async {
            self.theTable.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
     }
}
