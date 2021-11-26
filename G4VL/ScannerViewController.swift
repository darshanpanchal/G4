//
//  ScannerViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 31/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import Bugsnag
import Uploadcare

class ScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, G8TesseractDelegate {
    
    var appManager = AppManager.sharedInstance
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var detector : CIDetector?
    @IBOutlet var outputLabel : UILabel!
    
    var result : String?
    
    @IBOutlet var scanArea:UIView!
    
    var loaded = false
    var scanned = true
    
    var jobAppraisal : JobAppraisal {
        return AppManager.sharedInstance.currentJobAppraisal!
    }
    
    var pickup = true
    var entry : PlateVinEntry?
    
    
    @IBAction func back() {
        guard let _ = self.navigationController else {
            return
        }
        for controller in self.navigationController!.viewControllers as Array {
            if controller is JobViewController{
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
        
        
        //        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        print("Plate \(appManager.currentJob!.vehicle!.registrationNumber!.uppercased())")
        
        
        if pickup {
            entry = self.jobAppraisal.numberPlate!.pickup
        }
        else {
            entry = self.jobAppraisal.numberPlate!.dropoff
        }
        
        scanned = true
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if !loaded {
            loaded = true
            // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
            let captureDevice = AVCaptureDevice.default(for: .video)//AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            guard  let  _ = captureDevice else{
                return
            }
            do {
                // Get an instance of the AVCaptureDeviceInput class using the previous device object.
                let input = try AVCaptureDeviceInput(device: captureDevice!)
                
                // Initialize the captureSession object.
                captureSession = AVCaptureSession()
                
                // Set the input device on the capture session.
                captureSession?.addInput(input)
                
                
                
                let captureOutput = AVCaptureVideoDataOutput()
                captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Scanner"))
                captureOutput.connection(with: .video)
                //captureOutput.connection(withMediaType: AVMediaTypeVideo)
                
                if captureSession!.canAddOutput(captureOutput){
                    captureSession?.addOutput(captureOutput)
                }
                
                
                
                // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.videoGravity = .resizeAspectFill//AVLayerVideoGravityResizeAspectFill
                videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: (scanArea?.frame.size.width)!, height: (scanArea!.frame.size.height))
                scanArea.layer.addSublayer(videoPreviewLayer!)
                
                
                // Start video capture.
                captureSession?.startRunning()
                
                
                
            } catch {
                let exception = NSException(name:NSExceptionName(rawValue: "ScannerViewControllerloaded"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
                // If any error occurs, simply print it out and don't continue any more
                print(error)
                return
            }
            
            self.perform(#selector(ScannerViewController.delay), with: nil, afterDelay: 0.5)
        }
        
    }
    
    @objc func delay() {
        detector = prepareTextDetector()
        scanned = false
        
    }
    
    @IBAction func toggleFlash() {
        let device = AVCaptureDevice.default(for: .video)//AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureDevice.TorchMode.on) {
                    device?.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try device?.setTorchModeOn(level: 1.0)
                    } catch {
                        let exception = NSException(name:NSExceptionName(rawValue: "toggleFlash"),
                                                    reason:"\(error.localizedDescription)",
                            userInfo:nil)
                        Bugsnag.notify(exception)
                        print(error)
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                let exception = NSException(name:NSExceptionName(rawValue: "toggleFlash"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
                print(error)
            }
        }
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
//    }func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        if !scanned {
            scanned = true
            DispatchQueue.main.async {
                
                connection.videoOrientation = AVCaptureVideoOrientation.portrait;
                
                let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
                
                let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
                
                
                self.performTextDetection(image: ciimage)
            }
            
        }
        
    }
    
    
    
    
    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> UIImage
    {
        
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    
    func performImageRecognition(image: UIImage)->String {
        
        let tesseract:G8Tesseract = G8Tesseract(language: "eng")!
        tesseract.setVariableValue("0123456789ABCDEFGHJKLMNOPQRSTUVWXYZ", forKey: "tessedit_char_whitelist")
        tesseract.image = image
        tesseract.delegate = self
        
        tesseract.recognize();
        
        return tesseract.recognizedText ?? ""
    }
    
    
    func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    func prepareTextDetector() -> CIDetector {
        let options: [String: AnyObject] = [CIDetectorAccuracy: CIDetectorAccuracyHigh as AnyObject, CIDetectorImageOrientation : UIImage.Orientation.up as AnyObject]
        return CIDetector(ofType: CIDetectorTypeText, context: nil, options: options)!
    }
    
    
    
    func performTextDetection(image: CIImage)  {
        
        // Get the detections
        let features = detector?.features(in: image)
        
        
        if features?.count == 0 {
            scanned = false
            return
        }
        
        for feature in features as! [CITextFeature] {
            
            let ciimage = cropBusinessCardForPoints(image: image, topLeft: feature.topLeft, topRight: feature.topRight,
                                                    bottomLeft: feature.bottomLeft, bottomRight: feature.bottomRight)
            
            let uiimage =  self.convert(cmage: ciimage)
            
            let recognizedText = self.performImageRecognition(image: uiimage)
            
            var trimmed = recognizedText.replacingOccurrences(of: " ", with: "")
            trimmed = trimmed.replacingOccurrences(of: "\n", with: "")
            
            if trimmed.count > 7 {//is more than 2 lines
                self.scanned = false
            }else {
                if trimmed.count > 0 {
                    outputLabel.text = trimmed
                }
                
                if self.isRegCorrect(string: trimmed) {
                    
                    entry!.entry = .scanned
                    let objImage = self.convert(cmage: image)
                    let dateFormatter : DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    let date = Date()
                    let dateString = dateFormatter.string(from: date)
                    let updatedImage = objImage.textToImage(drawText: "\(self.jobAppraisal.jobID!) (\(trimmed)) (\(dateString))" as NSString, atPoint: CGPoint.init(x: 0, y: 0))
                    CustomPhotoAlbum.shared.save(image: updatedImage ?? objImage)
                    if let _ = updatedImage{
                        self.uploadImageToUploadCareAndUpdate(image: updatedImage!)
                    }
                    self.back()
                    break
               
                    
                }
                else {
                    self.scanned = false
                }
            }
        }
    }
    func uploadImageToUploadCareAndUpdate(image:UIImage){
        let filename = "\(AppManager.sharedInstance.currentJobAppraisal!.jobID!)-appraisal-\(GUID.generate()).jpg"
        entry!.photoName = filename
        entry!.uploadCarePhotoName = filename
        let path = OfflineFolderStructure.getAppraisalImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: AppManager.sharedInstance.currentJobAppraisal!.jobID!, pickup: pickup) + "/" + filename
        let data = image.jpegData(compressionQuality: 0.75)//UIImageJPEGRepresentation(updatedImage!, Defaults.compression);
        self.uploadScannerImageToUploadCare(imageData: data!, fileName: filename) { (success) in
            
            do {
                try data!.write(to: URL(string:path)!, options: Data.WritingOptions.atomicWrite)
                print("Photo Added");
            }
            catch {
                let exception = NSException(name:NSExceptionName(rawValue: "performTextDetection"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
            }
            
            DispatchQueue.main.async {
                if self.pickup {
                    self.jobAppraisal.status = .pickupAppraisalStarted
                    JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                    Requests.changeJobStatus(jobID: self.jobAppraisal.jobID!, status: .pickupAppraisalStarted)
                }
                else {
                    self.jobAppraisal.status = .dropoffAppraisalStarted
                    JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                    Requests.changeJobStatus(jobID: self.jobAppraisal.jobID!, status: .dropoffAppraisalStarted)
                }
                
            }
        }
    }
    func uploadScannerImageToUploadCare(imageData: Data,fileName: String,completion:@escaping (_ success:Bool)->()){
        
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
                self.entry!.photoName = fileName
                self.entry!.uploadCarePhotoName = url
                //self.expense!.uploadCarephotoReceiptName = url
                completion(true)
            }
        })
        
    }
    func captureScreen() -> UIImage? {
        
        guard let context = UIGraphicsGetCurrentContext() else { return .none }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            //            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            //            present(ac, animated: true)
        }
    }
    func cropBusinessCardForPoints(image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        
        var businessCard: CIImage
        businessCard = image.applyingFilter(
            "CIPerspectiveTransformWithExtent",
            parameters: [
                "inputExtent": CIVector(cgRect: image.extent),
                "inputTopLeft": CIVector(cgPoint: topLeft),
                "inputTopRight": CIVector(cgPoint: topRight),
                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                "inputBottomRight": CIVector(cgPoint: bottomRight)])
        businessCard = image.cropped(to: businessCard.extent)
        
        return businessCard
    }
    
    
    
    
    
    func isRegCorrect(string : String) -> Bool {
        let numPlate = appManager.currentJob!.vehicle!.registrationNumber!.uppercased().replacingOccurrences(of: " ", with: "")
        let stringFormatted = string.replacingOccurrences(of: " ", with: "").uppercased()
        
        if numPlate == stringFormatted {
            return true
        }
        
        if string.contains("O") || string.contains("I") {
            return numPlate == stringFormatted.replacingOccurrences(of: "O", with: "0").replacingOccurrences(of: "I", with: "1")
        }
        
        return false
    }
    
    
    @IBAction func manualEntry() {
        
        
        captureSession?.stopRunning()
        scanned = true
        var txt : UITextField?
        
        
        let alert = UIAlertController(title: "Enter Number Plate", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {
            textfield in
            txt = textfield
            txt?.enablesReturnKeyAutomatically = false
            txt?.autocapitalizationType = .allCharacters
            
        })
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {
            action in
            let trimmed = txt!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if self.isRegCorrect(string: trimmed.uppercased()) {
                
                self.entry!.entry = .manual
                self.entry!.reasonForSkipping = ""
                
                if self.pickup {
                    self.jobAppraisal.status = .pickupAppraisalStarted
                    JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                    Requests.changeJobStatus(jobID: self.jobAppraisal.jobID!, status: .pickupAppraisalStarted)
                }
                else {
                    self.jobAppraisal.status = .dropoffAppraisalStarted
                    JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                    Requests.changeJobStatus(jobID: self.jobAppraisal.jobID!, status: .dropoffAppraisalStarted)
                }
                
                self.back()
                
            }
            else {
                
                let alert1 = UIAlertController(title: "Wrong Number Plate", message: "The number plate you have entered \((txt!.text!.uppercased())) doesn't match the number plate for the job \(self.appManager.currentJob!.vehicle!.registrationNumber!)", preferredStyle: .alert)
                
                alert1.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                    action in
                    
                    
                    
                    self.captureSession?.startRunning()
                    alert1.dismiss(animated: true, completion: nil)
                    
                    
                }))
                
                self.present(alert1, animated: true, completion: nil)
                
            }
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            
            self.scanned = false
            
            self.captureSession?.startRunning()
            
            alert.dismiss(animated: true, completion: nil)
            
            
        }))
        
        DispatchQueue.main.async {
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    @IBAction func skip() {
        
        captureSession?.stopRunning()
        scanned = true
        
        var txt : UITextField?
        
        let alert = UIAlertController(title: "", message: "Please specifiy the reason for skipping.", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {
            textfield in
            txt = textfield
            txt?.enablesReturnKeyAutomatically = false
            
        })
        
        alert.addAction(UIAlertAction(title: "Skip", style: .default, handler: {
            action in
            
            if txt!.text!.trimmingCharacters(in: .whitespaces).count > 0 {
                
                self.entry!.entry = .skipped
                self.entry!.reasonForSkipping = txt!.text!
                
                if self.pickup {
                    self.jobAppraisal.status = .pickupAppraisalStarted
                    JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                    Requests.changeJobStatus(jobID: self.jobAppraisal.jobID!, status: .pickupAppraisalStarted)
                }
                else {
                    self.jobAppraisal.status = .dropoffAppraisalStarted
                    JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                    Requests.changeJobStatus(jobID: self.jobAppraisal.jobID!, status: .dropoffAppraisalStarted)
                }
                
                
                
                alert.dismiss(animated: true, completion: nil)
                
                self.back()
            }
            else {
                self.scanned = false
                
                self.captureSession?.startRunning()
            }
            
        }))
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            
            self.scanned = false
            
            self.captureSession?.startRunning()
            
            alert.dismiss(animated: true, completion: nil)
            
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
}



