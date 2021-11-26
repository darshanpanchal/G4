//
//  VehicalAssessmentViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 10/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MobileCoreServices
import Uploadcare

class VehicalAssessmentViewController: UIViewController,InspectionContainerDelegate, UITableViewDelegate, UITableViewDataSource, PhotoDelegate, SwitchCellDelegate, RadioCellDelegate, MeasureCellDelegate, NotesDelegate, SliderCellDelegate {
    
    
    
    var appManager = AppManager.sharedInstance
     @IBOutlet var progressControl : AssessmentProgressControl!
    @IBOutlet var inspectionContainer : InspectionContainer!
    @IBOutlet var theTable : UITableView!
    @IBOutlet var buttonPopover:UIButton!
    
    var pickup = true
    var entry : ManualAppraisalEntry?
    
    var jobAppraisal : JobAppraisal {
        return AppManager.sharedInstance.currentJobAppraisal!
    }
   
    
    var selectedPart : VehicleImage?
    var loaded = false
    @IBOutlet var lblPhotoCount : UILabel!

    var arrayOfImagesName:[String] = ["Front","Driver Side","Rear","Passenger Side"]
    var uploadCareURL:[String] = ["","","",""]
    lazy var objImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        appManager.progressControl = progressControl
        appManager.inspectionContainer = inspectionContainer
        inspectionContainer.delegate = self
        
        if jobAppraisal.manualAppraisal == nil {
            jobAppraisal.manualAppraisal = ManualAppraisal(pickupvalue: nil, dropoffvalue: nil)
        }else{
            if self.pickup {
                self.entry = jobAppraisal.manualAppraisal!.pickup
            }else {
                self.entry = jobAppraisal.manualAppraisal!.dropoff
               if jobAppraisal.status != .dropoffAppraisalComplete && jobAppraisal.status != .dropoffAppraisalStarted {
                   jobAppraisal.status = .dropoffAppraisalStarted
                   Requests.changeJobStatus(jobID: jobAppraisal.jobID!, status: .dropoffAppraisalStarted)
                   JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
               }
            }
                  
        }
        if entry!.photoNames != nil {
            
            let photoCount = entry!.photoNames!.count
            
            if photoCount == 1 {
                lblPhotoCount.text = "\(photoCount) photo added"
            }else {
                lblPhotoCount.text = "\(photoCount) photos added"
            }
            
        }
        
        let objNIb = UINib.init(nibName: "AppraisalTableViewCell", bundle: nil)
        theTable.register(objNIb, forCellReuseIdentifier: "AppraisalTableViewCell")
        theTable.separatorStyle = .none
        if let objEntry = entry{
            
                  if let objUploadURL = objEntry.front?.uploadCarePhotoNames{
                       self.uploadCareURL.remove(at: 0)
                       self.uploadCareURL.insert(objUploadURL, at: 0)
                   }
                   if let objUploadURL = objEntry.driverside?.uploadCarePhotoNames{
                       self.uploadCareURL.remove(at: 1)
                       self.uploadCareURL.insert(objUploadURL, at: 1)
                   }
                   if let objUploadURL = objEntry.rear?.uploadCarePhotoNames{
                       self.uploadCareURL.remove(at: 2)
                       self.uploadCareURL.insert(objUploadURL, at: 2)
                   }
                   if let objUploadURL = objEntry.passengerside?.uploadCarePhotoNames{
                       self.uploadCareURL.remove(at: 3)
                       self.uploadCareURL.insert(objUploadURL, at: 3)
                   }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VehicalAssessmentViewController.loadContent), name: NSNotification.Name(Notification.REFRESH_VEHICAL_DETAILS), object: nil)
        
        
        
        if !loaded {
            loaded = true
            loadContent()
        }else {
            inspectionContainer.updateView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }

    
    @objc func loadContent() {
        
        DispatchQueue.main.async {
            
            
            self.theTable.reloadData()
            
            self.appManager.inspectionContainer!.setup()
            
            self.progressControl.updateProgress()
            
            
        }
        
        
        
        
    }

    
    //MARK: Inspection Delegates
    
    func didSelectSection(section: VehicleImage) {
        
        if !section.enable {
            return
        }
        
        let customAlert : CustomAlert = CustomAlert.instanceFromNib() as! CustomAlert
        
        customAlert.v.layer.shadowColor = UIColor.black.cgColor
        customAlert.v.layer.shadowOffset = CGSize(width: 5, height: 5)
        customAlert.v.layer.shadowOpacity = 0.4
        customAlert.v.layer.shadowRadius = 8.0
        
        
        let newString = VehicleSections.readibleCarParts(part: section.part!).uppercased()
        
        customAlert.titleLabel.text = newString
        
        customAlert.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        customAlert.yesCompletionHandler = {
            customAlert.hide()
            
            
            VehiclePartAnalysis.markAssociatedPartAsChecked(associatedPart: section.part!,noDamage: true,pickup: self.pickup)
            
            
        }
        
        customAlert.noCompletionHandler = {
            customAlert.hide()
            self.selectedPart = section
            
            self.performSegue(withIdentifier: "to_vehicle_part", sender: section)
            
        }
        
        self.view.addSubview(customAlert)
        customAlert.show()
        
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "to_vehicle_part" {
            var counter = 0
            for part in entry!.vehicleParts! {
                if part.name == self.selectedPart?.part {
                    
                    
                    let vc = segue.destination as! CarPartAssessmentViewController
                    vc.pickup = pickup
                    vc.index = counter
                    vc.image = UIImage(named: self.selectedPart!.focusImage!)
                    
                    if inspectionContainer.currentPerspective?.title(for: .normal)?.lowercased() == "driver side" {
                        vc.flipped = true
                    }
                    break;
                
                }
                counter += 1
            }
        }
        else if segue.identifier == "to_photos_from_assessment" {
            let vc = segue.destination as! PhotoViewController
            vc.photoDelegate = self
            vc.pickup = pickup
            if entry!.photoNames != nil {
                vc.photoNames = entry!.photoNames!
                vc.uploadCareURL = entry!.uploadCarePhotoNames!
                
            }
            
        }
        
    }

    
    //MARK: TableView Delegate/Datasource
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if jobAppraisal.manualAppraisal == nil || entry!.vehicleDetailSections == nil {
            return 0
        }
        
        return entry!.vehicleDetailSections!.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.arrayOfImagesName.count
        }else{
            let rows = entry!.vehicleDetailSections![section-1]
            
            return rows.vehicleDetailRows!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell : AppraisalTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AppraisalTableViewCell") as! AppraisalTableViewCell
           
            cell.backgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
            cell.separatorInset = UIEdgeInsets.zero
            cell.lblTitle.text = "\(self.arrayOfImagesName[indexPath.row])"
            cell.delegate = self
            cell.buttonImageVehicle.tag = indexPath.row
            DispatchQueue.main.async {
                if self.uploadCareURL.count > indexPath.row,self.uploadCareURL[indexPath.row].count > 0,let objURL = URL.init(string:self.uploadCareURL[indexPath.row]){
                   cell.imageViewVehicle.load(url: objURL)
                }else{
                    cell.imageViewVehicle.image = UIImage.init(named: "camera_100")
                }
                
            }
            return cell
        }else{
            
       
        
        let vehicleSection = entry!.vehicleDetailSections![indexPath.section-1]
        
        let vehicleRow = vehicleSection.vehicleDetailRows![indexPath.row]
        
        let identifier = vehicleRow.identifier!
        
        var title = (vehicleRow.label!)
        
        if title.count == 0 {
            title = vehicleSection.label!
        }
        
        title = title.replacingOccurrences(of: " ", with: "_").lowercased()
        
        if identifier == .radio {
            let cell : RadioTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue) as! RadioTableViewCell
            
            let options = vehicleRow.options!
            
            cell.options = options
            cell.indexPath = indexPath
            cell.delegate = self
            cell.title = title
            
            if Int(vehicleRow.selected!) == 0 {
                cell.selectedOption = ""
            }else{
                cell.selectedOption = options[Int(vehicleRow.selected!-1)]
            }
            cell.setOptions()
            return cell
        }
        
        else if identifier == .identifierSwitch{
            let cell : SwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue) as! SwitchTableViewCell
            
            cell.titleLabel.text = vehicleRow.label!
            cell.title = title
            cell.delegate = self
            cell.sw.isOn = vehicleRow.state!
            cell.indexPath = indexPath
            
            return cell
        }
            
        else if identifier == .slider {
            let cell : SliderTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue) as! SliderTableViewCell
            
            cell.delegate = self
            cell.stepSize = Float(vehicleRow.step!)
            cell.slider.value = Float(vehicleRow.value)
            cell.previousValue = Float(vehicleRow.value)
            cell.slider.maximumValue = Float(vehicleRow.max!)
            cell.slider.minimumValue = 0
            cell.valueLabel.text = "\(Int(vehicleRow.value))"
            cell.indexPath = indexPath
            return cell
        }
            
        else if identifier == .measure {
            let cell : MeasureTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue) as! MeasureTableViewCell
            
            cell.lblTitle.text = vehicleRow.label!
            cell.lblUnits.text = vehicleRow.units!
            cell.lblDescription.text = vehicleRow.desc!
            cell.indexPath = indexPath
            cell.txtMeasure.text = "\(vehicleRow.value ?? 0.0)"
            cell.delegate = self
            
            
            
            return cell
        }
        
        else if identifier == .notes {
            let cell : NotesTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue) as! NotesTableViewCell
            cell.txtNotes.text = vehicleRow.text ?? ""
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        }
        
         }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == entry!.vehicleDetailSections!.count - 1 {
            
            let rows = entry!.vehicleDetailSections![indexPath.section]
            
            if indexPath.row == rows.vehicleDetailRows!.count - 1 {
                
                appManager.progressControl!.updateProgress()
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 240
        }else{
            let vehicleSection = entry!.vehicleDetailSections![indexPath.section - 1]
            
            let vehicleRow = vehicleSection.vehicleDetailRows![indexPath.row]
            
            let identifier = vehicleRow.identifier!
            
            if identifier == .notes {
                return 250
            }
            
            return 60
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
                  return 60
        }else{
            let vehicleSection = entry!.vehicleDetailSections![indexPath.section-1]
            
            let vehicleRow = vehicleSection.vehicleDetailRows![indexPath.row]
            
            let identifier = vehicleRow.identifier!
            
            if identifier == .notes {
                return 250
            }
            else  if identifier == .measure{
                return UITableView.automaticDimension
            }
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return nil
        }else{
            let vehicleSection = entry!.vehicleDetailSections![section - 1]
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
            view.backgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
            
            let lbl = UILabel(frame: CGRect(x: 20, y: 20, width: tableView.frame.size.width-40, height: 40))
            lbl.backgroundColor = UIColor.clear
            lbl.font = UIFont(name: "JosefinSans-Bold", size: 17)
            lbl.text = vehicleSection.label!.uppercased()
            view.addSubview(lbl)
            
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }else{
            return 60;
        }
    }
    
    //MARK: Cell Delegates
    
    
    func didUpdateSlider(cell: SliderTableViewCell) {
        
        let vehicleSection = entry!.vehicleDetailSections![cell.indexPath!.section - 1]
        
        let vehicleRow = vehicleSection.vehicleDetailRows![cell.indexPath!.row]
        
        vehicleRow.value = Double(cell.slider.value)
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
        
        if vehicleRow.key == "number_of_keys" {
            var title = (vehicleRow.label!)
            
            if title.count == 0 {
                title = vehicleSection.label!
            }
            
            title = title.replacingOccurrences(of: " ", with: "_").lowercased()
            
            if Int(vehicleRow.value!) == 0 {
                appManager.completedSections.remove(title)
            }
            else {
                appManager.completedSections.appendWithoutDuplication(title)
            }
            
            appManager.progressControl!.updateProgress()
        }
        
        
        
    }
    
    func didToggleSwitch(cell: SwitchTableViewCell) {
        print(cell.sw.isOn)
        let vehicleSection = entry!.vehicleDetailSections![cell.indexPath!.section - 1]
        
        let vehicleRow = vehicleSection.vehicleDetailRows![cell.indexPath!.row]
        
        vehicleRow.state = cell.sw.isOn
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
    }
    
    func didSelectOption(cell: RadioTableViewCell) {
        
        let vehicleSection = entry!.vehicleDetailSections![cell.indexPath!.section - 1]
        
        let vehicleRow = vehicleSection.vehicleDetailRows![cell.indexPath!.row]
        
        let index = vehicleRow.options!.index(of: cell.selectedOption)
        
        vehicleRow.selected = Int(index!) + 1
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
        
        
        var title = (vehicleRow.label!)
        
        if title.count == 0 {
            title = vehicleSection.label!
        }
        
        title = title.replacingOccurrences(of: " ", with: "_").lowercased()
        
        if Int(vehicleRow.selected!) == 0 {
            appManager.completedSections.remove(title)
        }
        else {
            appManager.completedSections.appendWithoutDuplication(title)
        }
        
        appManager.progressControl!.updateProgress()
    }
    
    func updateMeasureValue(value: String, cell: MeasureTableViewCell) {
        let vehicleSection = entry!.vehicleDetailSections![cell.indexPath!.section - 1]
        
        let vehicleRow = vehicleSection.vehicleDetailRows![cell.indexPath!.row]
        
        vehicleRow.value = (value as NSString).doubleValue
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
        
        if vehicleRow.value == 0.0 {
            appManager.completedSections.remove(vehicleRow.label!)
        }else{
            appManager.completedSections.appendWithoutDuplication(vehicleRow.label!)
        }
        appManager.progressControl!.updateProgress()
    }
    
    func updateNotes(value: String, cell: NotesTableViewCell) {
        
        let vehicleSection = entry!.vehicleDetailSections![cell.indexPath!.section - 1]
        
        let vehicleRow = vehicleSection.vehicleDetailRows![cell.indexPath!.row]
        
        vehicleRow.text = value
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
        
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
    }
    
   
    
    
    
    @IBAction func completeAssessment() {
        self.entry!.complete = true
        
        JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
        
        self.view.isUserInteractionEnabled = false
        
        self.perform(#selector(self.back), with: nil, afterDelay: 0.2)
    }

}
extension VehicalAssessmentViewController: AppraisalCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func buttonImagePickerSelector(tag: Int) {
        print(tag)
        self.presentImagePickerWithTagFromDelegate(tag: tag)
    }
    func presentImagePickerController(tag:Int){
        self.view.endEditing(true)
        self.objImagePickerController.view.tag  = tag // ["Front","Driver Side","Rear","Passenger Side"]
        self.present(self.objImagePickerController, animated: true, completion: nil)
    }
    func presentImagePickerWithTagFromDelegate(tag:Int){
        let actionSheetController = UIAlertController.init(title: "", message:"Photos", preferredStyle: .actionSheet)
                       let cancelSelector = UIAlertAction.init(title: "Cancel", style: .cancel, handler:nil)
                       actionSheetController.addAction(cancelSelector)
                       
                       let cameraSelector = UIAlertAction.init(title: "Camera", style: .default) { (_) in

                           DispatchQueue.main.async {
                               self.objImagePickerController = UIImagePickerController()
                               self.objImagePickerController.sourceType = .camera
                               self.objImagePickerController.delegate = self
                               self.objImagePickerController.allowsEditing = true
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
                       actionSheetController.addAction(photosSelector)
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
             
             guard let _ = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                 dismiss(animated: true, completion: nil)
                 return
             }
             dismiss(animated: true, completion: nil)
             return
         }
         
        // ["Front","Driver Side","Rear","Passenger Side"]
        self.uploadCareWithPhotoNames(objImage: originalImage, tag: picker.view.tag)
        /*
         if picker.view.tag == 0 { //front
            
         if picker.view.tag == 1 { //for arraival
             self.uploadImageToUploadCare(objImage: originalImage,isForAppraisal: true)
         }else if picker.view.tag == 2{ //for completion
             self.uploadImageToUploadCare(objImage: originalImage,isForAppraisal: false)
         }else if picker.view.tag == 3{ //for completion
             self.uploadWasteNoteImageToUploadCare(objImage: originalImage)
         }else{
             
         }*/
         picker.dismiss(animated: true, completion: nil)
         
         //self.presentImageEditor(image: originalImage)
     }
        func uploadCareWithPhotoNames(objImage:UIImage,tag:Int){
           DispatchQueue.main.async {
               ProgressHud.show()
           }
            let fileName = "\(AppManager.sharedInstance.currentJobAppraisal!.jobID!)-appraisal-\(GUID.generate()).jpg"//"\(GUID.generate()).jpg"

            //var fileName = self.arrayOfImagesName[tag].replacingOccurrences(of:" ", with:"")
               if let imageData = objImage.jpegData(compressionQuality: 0.50){
                let uploadCareRequest = UCFileUploadRequest.init(fileData: imageData, fileName: fileName, mimeType:"image/jpeg")
                   UCClient.default()?.performUCRequest(uploadCareRequest, progress: { (totalBytesSent, totalBytesExpectedToSend) in
                       print(totalBytesSent)
                       print(totalBytesExpectedToSend)
                   }, completion: { (response, error) in
                       DispatchQueue.main.async {
                           ProgressHud.hide()
                       }
                       if let _ = error{
                           print("\nError :-\n\(error!.localizedDescription)")
                           
                       }else{
                           print("\nSuccess :-\n\(response ?? "")")
                           if let objResponse = response as? [String:Any],let udid = objResponse["file"]{
                               let url = "\(NSString.uc_path(withUUID: "\(udid)") ?? "")\(fileName.replacingOccurrences(of:"-", with:""))"
                               let objIndex = tag
                               if self.uploadCareURL.count+1 > objIndex {
                                   self.uploadCareURL.remove(at: objIndex)
                                   self.uploadCareURL.insert(url, at: objIndex)
                               }
                            
                            // ["Front","Driver Side","Rear","Passenger Side"]
                           
                            if tag == 0 {
                                var frontentry:ManualAppraisalEntry?
                                if self.pickup{
                                      frontentry = self.jobAppraisal.manualAppraisal!.pickup
                                }else{
                                      frontentry = self.jobAppraisal.manualAppraisal!.dropoff
                                }
                                let obj = Front.init(photoNames: fileName, uploadCarePhotoNames: url)
                                 if let _ = frontentry{
                                    frontentry!.front = obj
                                 }
                                var title = obj.label
                                title = title.replacingOccurrences(of: " ", with: "_").lowercased()
                                title.append(" image")
                                self.appManager.completedSections.appendWithoutDuplication(title)
                                JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                            }else if tag == 1{
                                var driversideentry:ManualAppraisalEntry?
                                if self.pickup{
                                      driversideentry = self.jobAppraisal.manualAppraisal!.pickup
                                }else{
                                      driversideentry = self.jobAppraisal.manualAppraisal!.dropoff
                                }
                                let  obj = DriverSide.init(photoNames: fileName, uploadCarePhotoNames: url)
                                if let _ = driversideentry{
                                    driversideentry!.driverside = obj
                                }
                                var title = obj.label
                                title = title.replacingOccurrences(of: " ", with: "_").lowercased()
                                title.append(" image")
                                self.appManager.completedSections.appendWithoutDuplication(title)
                                JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                            }else if tag == 2{
                                var Rearentry:ManualAppraisalEntry?
                                if self.pickup{
                                      Rearentry = self.jobAppraisal.manualAppraisal!.pickup
                                }else{
                                      Rearentry = self.jobAppraisal.manualAppraisal!.dropoff
                                }
                                let obj = Rear.init(photoNames: fileName, uploadCarePhotoNames: url)
                                if let _ = Rearentry{
                                    Rearentry!.rear = obj
                                }
                                var title = obj.label
                                title = title.replacingOccurrences(of: " ", with: "_").lowercased()
                                title.append(" image")
                                self.appManager.completedSections.appendWithoutDuplication(title)
                                JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                            }else if tag == 3{
                                var PassengerSideentry:ManualAppraisalEntry?
                                if self.pickup{
                                      PassengerSideentry = self.jobAppraisal.manualAppraisal!.pickup
                                }else{
                                      PassengerSideentry = self.jobAppraisal.manualAppraisal!.dropoff
                                }
                                let obj = PassengerSide.init(photoNames: fileName, uploadCarePhotoNames: url)
                                if let _ = PassengerSideentry{
                                    PassengerSideentry!.passengerside = obj
                                }
                                var title = obj.label
                                title = title.replacingOccurrences(of: " ", with: "_").lowercased()
                                title.append(" image")
                                self.appManager.completedSections.appendWithoutDuplication(title)
                                JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                            }

                               DispatchQueue.main.async {
                                self.appManager.progressControl!.updateProgress()
                                self.theTable.reloadData()
                               
                                
                                   //self.photoDelegate?.updatePhotos(photoNames: self.photoNames)
                                   //self.photoDelegate?.updatePhotos(photoNames: self.photoNames, uploadCare: self.uploadCareURL)
                               }
                           }
                       }
                   })
               }else{
                   DispatchQueue.main.async {
                       ProgressHud.hide()
                   }
               }
        
     
}


}
