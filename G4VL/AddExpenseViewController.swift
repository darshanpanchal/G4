//
//  AddExpenseViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 28/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import ImagePicker
import Bugsnag
import Uploadcare
class AddExpenseViewController: UIViewController, ImagePickerDelegate, UITextFieldDelegate {

    
    
    
    let appManager = AppManager.sharedInstance
    @IBOutlet var txtDescription : UITextField!
    @IBOutlet var txtCost : UITextField!
    var expense : Expense?
    var photoChanged = false
    var photo : UIImage?
    @IBOutlet var photoImageView : UIImageView!
    
    @IBOutlet var jetWashSwitch : SegmentSwitch!
    @IBOutlet var descriptionView : UIView!
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let _ = appManager.currentUser else {
            return
        }
        if expense != nil {
            txtCost.text = expense!.getReadableCost(withSign: false)
            txtDescription.text = expense!.itemDescription
            
            jetWashSwitch.isOn = expense!.isJetWash
            descriptionView.isHidden = jetWashSwitch.isOn
            
            var path = OfflineFolderStructure.getExpensesImagesPath(driverID: appManager.currentUser!.driverID!, jobID: appManager.currentJobAppraisal!.jobID!)
            
            path += "/\(expense!.photoReceiptName!)"
            
            photo = UIImage(contentsOfFile: path.replacingOccurrences(of: "file://", with: ""))
            photoImageView.image = photo
            photoImageView.contentMode = .scaleAspectFill
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func showPhotoOptions() {
        
        let configuration = Configuration()
        configuration.doneButtonTitle = "Finish"
        configuration.noImagesTitle = "Sorry! There are no images here!"
        configuration.allowMultiplePhotoSelection = false
        configuration.canRotateCamera = true
        configuration.cancelButtonTitle = "Cancel"
        
        
        
        let imagePickerController = ImagePickerController(configuration: configuration)
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
        
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
       
        photo = images[0]
        
        if !photo!.isImageBlurry() {
            photoImageView.image = photo
            photoImageView.contentMode = .scaleAspectFill
            imagePicker.dismiss(animated: true, completion: nil)
            
            
        }
        else {
            
            
            let alert = UIAlertController(title: "Warning", message: "Photo is too blurry please retake or select another photo", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                action in
               alert.dismiss(animated: true, completion: nil)
            }))
            
            imagePicker.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }

    
    //MARK: Textfield Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        
        if Int(string) != nil {
            return true
        }
        
        if string  == "." && !textField.text!.contains(".") && string.count != 0 {
            //string is '.' and doesn't already contain a '.' and a number has already been entered
            return true
        }
        
        if string == "" && textField.text!.count > 0 {
            return true
        }
        
        return false
    }
    
    
    //MARK: Save Changes
    
    
    func isValid()->Bool {
        if !self.descriptionView.isHidden{
            if txtDescription.text!.trimmingCharacters(in: .whitespaces).count < 1 {
                let alert = SimpleAlert.dismissAlert(message: "Please enter a description", title: "", cancel: "OK")
                self.present(alert, animated: false, completion: nil)
                return false
            }
        }
        
        if txtCost.text!.trimmingCharacters(in: .whitespaces).count < 1 {
            let alert = SimpleAlert.dismissAlert(message: "Please enter a cost", title: "", cancel: "OK")
            self.present(alert, animated: false, completion: nil)
            return false
        }
        
        if photo == nil {
            let alert = SimpleAlert.dismissAlert(message: "Please add a photo of the receipt", title: "", cancel: "OK")
            self.present(alert, animated: false, completion: nil)
            return false
        }
        
        return true
    }
    
    @IBAction func saveChanges() {
        
        if isValid() {
            do {
                var index = -1
                if expense == nil {
                    expense = Expense(cost: nil, itemDescription: nil, photoReceiptName: nil, isJetWash: nil)
                    let imageName = "\(GUID.generate()).jpg"
                    expense!.uploadCarephotoReceiptName = "\(appManager.currentJobAppraisal!.jobID!)-expense-\(imageName)"
                    expense!.photoReceiptName = "\(appManager.currentJobAppraisal!.jobID!)-expense-\(imageName)"
                }else {
                    let result = appManager.currentJobAppraisal!.expenses.filter {
                        return $0.photoReceiptName == expense!.photoReceiptName
                    }
                    if result.count > 0 {
                        index = appManager.currentJobAppraisal!.expenses.index(of:result.first!)!
                    }
                }
                let photoData = photo!.jpegData(compressionQuality: 0.75)//UIImageJPEGRepresentation(photo!, Defaults.compression);
                guard let _ = AppManager.sharedInstance.currentUser else {
                    return
                }
                var path = OfflineFolderStructure.getExpensesImagesPath(driverID: appManager.currentUser!.driverID!, jobID: appManager.currentJobAppraisal!.jobID!)
                
                path += "/\(expense!.photoReceiptName!)"
                try photoData!.write(to: URL(string:path)!, options: .atomicWrite)
                self.uploadExpenseImageToUploadCare(imageData: photoData!, fileName: expense!.photoReceiptName!) { (success) in
                    DispatchQueue.main.async {
                        self.expense!.setCost(string: self.txtCost.text!)
                        self.expense!.itemDescription = self.txtDescription.text?.trimmingCharacters(in: .whitespaces)
                        self.expense!.setIsJetWash(self.jetWashSwitch.isOn)
                        
                        if index == -1 {
                            //new expense
                            self.appManager.currentJobAppraisal!.expenses.append(self.expense!)
                        }else {
                            //existing expense
                            self.appManager.currentJobAppraisal!.expenses[index] = self.expense!
                        }
                        JobsManager.saveJobAppraisal(job: self.appManager.currentJobAppraisal!, saveExpenses: true)
                        self.back()
                    }
                }
//                self.uploadExpenseImageToUploadCare(imageData: photoData!, fileName: expense!.photoReceiptName!,completion: )
            
            }catch {
                let exception = NSException(name:NSExceptionName(rawValue: "AdExpenseSaveChanges"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
                print("Error: \(error.localizedDescription)")
                let alert = SimpleAlert.dismissAlert(message: "The expense could not be saved. Please try again.", title: "", cancel: "OK")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func uploadExpenseImageToUploadCare(imageData: Data,fileName: String,completion:@escaping (_ success:Bool)->()){
        
            DispatchQueue.main.async {
                ProgressHud.show()
            }
            let uploadCareRequest = UCFileUploadRequest.init(fileData: imageData, fileName: "\(fileName)", mimeType:"image/jpeg")
        
            UCClient.default()?.performUCRequest(uploadCareRequest, progress: { (totalBytesSent, totalBytesExpectedToSend) in
                
            }, completion: { (response, error) in
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                if let _ = error{
                    print("\nError :-\n\(error!.localizedDescription)")
                    completion(false)
                }else if let objResponse = response as? [String:Any],let udid = objResponse["file"]{
                    print(objResponse)
                    let url = "\(NSString.uc_path(withUUID: "\(udid)") ?? "")\(fileName.replacingOccurrences(of:"-", with:""))"
                    self.expense!.uploadCarephotoReceiptName = url
                    completion(true)
                }
            })
        
    }
    @IBAction func jetWashToggled(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.jetWashSwitch.isOn = !self.jetWashSwitch.isOn
            self.descriptionView.isHidden = self.jetWashSwitch.isOn
        }
    }
    
    
   
}
