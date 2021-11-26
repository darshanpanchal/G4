//
//  PSignOffViewController.swift
//  G4VL
//
//  Created by Michael Miller on 04/06/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit
import Bugsnag
import Uploadcare

class SignOffViewController: UIViewController, SignDelegate {

    let appManager = AppManager.sharedInstance
    @IBOutlet var signatureImageView : UIImageView!
    @IBOutlet var txtSignedBy : UITextField!
    @IBOutlet var txtSurname:UITextField!
    
    @IBOutlet var segmentDriverUniform:UISegmentedControl!
    @IBOutlet var segmentExperience:UISegmentedControl!
    @IBOutlet var segmentDriverPolite:UISegmentedControl!
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }
    
    var jobAppraisal : JobAppraisal {
        return appManager.currentJobAppraisal!
    }
    
    var pickup = true
    var entry : SignatureEntry?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if jobAppraisal.signatures == nil {
            jobAppraisal.signatures = Signatures(pickup: nil, dropoff: nil)
        }
        
        if jobAppraisal.signatures!.dropoff == nil {
            jobAppraisal.signatures?.dropoff = SignatureEntry(label: "Dropoff",signatureFileName: nil, signedBy: nil, dateSigned: nil, uploadcareImageUrl: nil)
        }
        
        if pickup {
            entry = jobAppraisal.signatures!.pickup
        }else {
            entry = jobAppraisal.signatures!.dropoff
        }
        
        if let objWellDress = entry!.welldress,let objValues = objWellDress.values,objValues.count > 0{
            self.segmentDriverUniform.selectedSegmentIndex = objValues.first! == "Yes" ? 1 : 0
        }
        if let objBehaviour = entry!.driverbehaviour,let objValues = objBehaviour.values,objValues.count > 0{
            self.segmentDriverPolite.selectedSegmentIndex = objValues.first! == "Yes" ? 1 : 0
        }
        if let objExperience = entry!.driverexperience,let objValues = objExperience.values,objValues.count > 0{
            if objValues.first! == "Poor"{
                self.segmentExperience.selectedSegmentIndex = 0
            }else if objValues.first! == "Good"{
                self.segmentExperience.selectedSegmentIndex = 1
            }else{
                self.segmentExperience.selectedSegmentIndex = 2
            }
        }
        if let fullname = entry?.signedBy{
            let objarray = fullname.components(separatedBy:"-")
            if objarray.count > 1{
                self.txtSignedBy.text = objarray[0]
                self.txtSurname.text = objarray[1]
            }else if objarray.count > 0{
                self.txtSignedBy.text = objarray[0]
            }
        }
//        txtSignedBy.text = entry!.signedBy ?? ""
        
        if entry!.signatureFileName != nil {
            
            let path = OfflineFolderStructure.getSignatureImagesPath(driverID: appManager.currentUser!.driverID!, jobID: jobAppraisal.jobID!, pickup: pickup) + "/" + entry!.signatureFileName!
            
            let image  = UIImage(contentsOfFile: path.replacingOccurrences(of: "file://", with: ""))!

            signatureImageView.image = UIImage(cgImage: image.cgImage!, scale: UIScreen.main.scale, orientation: UIImage.Orientation.up)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func signature() {
        if txtSignedBy.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please add a fore name")
            return
        }
        if txtSurname.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please add a surname name")
            return
        }
        print(self.segmentDriverUniform.selectedSegmentIndex)
        print(self.segmentExperience.selectedSegmentIndex)
        print(self.segmentDriverPolite.selectedSegmentIndex)
        
        if self.segmentDriverUniform.selectedSegmentIndex == -1 {
            self.view.makeToast("Please answer driver's uniform question.")
            return
        }
        if self.segmentExperience.selectedSegmentIndex == -1 {
            self.view.makeToast("Please answer driver's experience question.")
            return
        }
        if self.segmentDriverPolite.selectedSegmentIndex == -1 {
            self.view.makeToast("Please answer driver's behaviour question.")
            return
        }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        entry!.dateSigned = df.string(from: Date())
        entry!.signedBy = "\(txtSignedBy.text!)-\(txtSurname.text!)"
        self.performSegue(withIdentifier: "to_sign", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to_sign" {
            let vc = segue.destination as! SignatureViewController
            vc.delegate = self
            vc.showAppraisal = true
            vc.pickup = pickup
            vc.entry = self.entry
        }
    }
    
    func confirmSignature(image: UIImage,model:[String],telepod:[String],paperwork:[String],iscaptureImage:Bool = false) {
        if iscaptureImage{
            signatureImageView.image = image
        }else {
            signatureImageView.image = UIImage(cgImage: image.cgImage!, scale: UIScreen.main.scale, orientation: UIImage.Orientation.up)
        }
        
        let singatureName = "\(jobAppraisal.jobID!)-signature-\(GUID.generate()).jpg"
        
        if entry!.signatureFileName == nil || entry!.signatureFileName!.count == 0 {
            entry!.signatureFileName = singatureName
            entry!.uploadcareImageUrl = singatureName
        }
        if !pickup{
            entry!.model?.values = model
            entry!.telepod?.values = telepod
            entry!.otherpaperwork?.values = paperwork
        }
        
        
        let path = OfflineFolderStructure.getSignatureImagesPath(driverID: appManager.currentUser!.driverID!, jobID: jobAppraisal.jobID!, pickup: pickup) + "/" + entry!.signatureFileName!
        print(path.description)
        let data = signatureImageView.image!.jpegData(compressionQuality: 0.0)//UIImageJPEGRepresentation(signatureImageView.image!, Defaults.compression);
        
        do {
            if let objImage = UIImage.init(data: data!){
                let dateFormatter : DateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let date = Date()
                let dateString = dateFormatter.string(from: date)
                let updatedImage = objImage.textToImage(drawText: "\(entry?.signedBy ?? "") (\(dateString))" as NSString, atPoint: CGPoint.init(x: 0, y: 0))
                if let _ = updatedImage{
                    updatedImage!.accessibilityValue = "\(iscaptureImage)"
                }
                signatureImageView.image = updatedImage
                CustomPhotoAlbum.shared.save(image: updatedImage ?? objImage)
                //UIImageWriteToSavedPhotosAlbum(updatedImage ?? objImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                if let _ = updatedImage{
                    let updateddata = signatureImageView.image!.jpegData(compressionQuality: 0.0)//UIImageJPEGRepresentation(signatureImageView.image!, Defaults.compression);
                    try updateddata!.write(to: URL(string:path)!, options: Data.WritingOptions.atomicWrite)
                    self.uploadSignatureImageToUploadCare(imageData: updateddata!,fileName: singatureName)
                }
            }
           
            
            //try data!.write(to: URL(string:path)!, options: Data.WritingOptions.atomicWrite)
            
            print("signature image saved");
        }
        catch {
            let exception = NSException(name:NSExceptionName(rawValue: "confirmSignature"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            self.view.makeToast("An error occurred while trying to save the signature")
            print("Photo not added");
        }
        
    }
    func uploadSignatureImageToUploadCare(imageData:Data,fileName:String){
        //let singatureName = "\(jobAppraisal.jobID!)-signature-\(GUID.generate()).jpg"
        
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
            }else if let objResponse = response as? [String:Any],let udid = objResponse["file"]{
                print(objResponse)
                let url = "\(NSString.uc_path(withUUID: "\(udid)") ?? "")\(fileName.replacingOccurrences(of:"-", with:""))"
                self.entry!.uploadcareImageUrl = url
            }
        })
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
            print("Saved error")

        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            print("Saved!")
//            present(ac, animated: true)
        }
    }
    @IBAction func signOff() {
        if signatureImageView.image == nil {
            self.view.makeToast("Please add a signature")
            return
        }
        
        if txtSignedBy.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please add a fore name")
            return
        }
        if txtSurname.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please add a sur name")
            return
        }
        self.view.makeToastActivity(.center)
        self.view.isUserInteractionEnabled = false
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        entry!.dateSigned = df.string(from: Date())
        entry!.signedBy = "\(txtSignedBy.text!)-\(txtSurname.text!)"
        entry!.welldress?.values = (self.segmentDriverUniform.selectedSegmentIndex == 0) ? ["No"] : ["Yes"]
        if self.segmentExperience.selectedSegmentIndex == 0{
            entry!.driverexperience?.values = ["Poor"]
        }else if self.segmentExperience.selectedSegmentIndex == 1{
            entry!.driverexperience?.values = ["Good"]
        }else{
            entry!.driverexperience?.values = ["Very Good"]
        }
        entry!.driverbehaviour?.values = (self.segmentDriverPolite.selectedSegmentIndex == 0) ? ["No"] : ["Yes"]
        
        if pickup {
            jobAppraisal.status = .pickupAppraisalComplete
            JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
            Requests.changeJobStatus(jobID: jobAppraisal.jobID!, status: .pickupAppraisalComplete)
            self.back()

        }else {
            jobAppraisal.status = .dropoffAppraisalComplete
            JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
            Requests.changeJobStatus(jobID: jobAppraisal.jobID!, status: .dropoffAppraisalComplete)
            for controller in self.navigationController!.viewControllers as Array {
                if controller is MapProgressViewController{
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
        
        
        
    }

}
