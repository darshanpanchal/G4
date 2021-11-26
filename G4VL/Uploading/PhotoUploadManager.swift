//
//  UploadManager.swift
//  G4VL
//
//  Created by Michael Miller on 28/03/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit
import Bugsnag

private class TemporaryImageObject {
    var jobID = 0
    var path = ""
    var filename = ""
    var imageType : ImageType?
}

private enum ImageType {
    case appraisal
    case expense
    case signature
    case fleet
}

protocol PhotoUploadManagerDelegate {
    func finishedPhotoUploadCycle()
}

class PhotoUploadManager: NSObject {

    
    var delegate : PhotoUploadManagerDelegate?
    
    private var currentCycle : [TemporaryImageObject] = []
    
    var inUploadCycle = false {
        didSet {
            if !inUploadCycle {
                self.delegate?.finishedPhotoUploadCycle()
            }
        }
    }
    
    
    
    func checkForWaitingUploads() {
        if inUploadCycle {
            return
        }
        
        inUploadCycle = true
        /*
        
        currentCycle = []
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        let path = OfflineFolderStructure.getDriverPath(id: AppManager.sharedInstance.currentUser!.driverID!)
        
        let fileManager = FileManager.default
        do {
            let folderURLS = try fileManager.contentsOfDirectory(at: URL(string:path)!, includingPropertiesForKeys: nil)
            
            if folderURLS.count > 0 {
                
                checkImages(folders: folderURLS, pickup: true)
                checkImages(folders: folderURLS, pickup: false)
                
               
                if currentCycle.count > 0 {
                    upload()
                }
                else {
                    inUploadCycle = false
                }
                
            }
            else {
                inUploadCycle = false
            }
            
            // process files
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
            let exception = NSException(name:NSExceptionName(rawValue: "checkForWaitingUploads"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            inUploadCycle = false
        }
        */
        
    }
    
    func checkImages(folders : [URL], pickup : Bool) {
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        let driverId = AppManager.sharedInstance.currentUser!.driverID!
        
        for folderURL in folders {
            
            let jobID = (folderURL.lastPathComponent.replacingOccurrences(of: "job_", with: "") as NSString).integerValue
            
            print(OfflineFolderStructure.doesPodFileExist(driverID: driverId, jobID: jobID) )
            
            if pickup && OfflineFolderStructure.doesPodFileExist(driverID: driverId, jobID: jobID) {//only allow pickup image once the POD file has been generated
                addImagesToCycle(jobID: jobID, imagePath: OfflineFolderStructure.getAppraisalImagesPath(driverID: driverId, jobID: jobID, pickup: true), type: .appraisal)
                addImagesToCycle(jobID: jobID, imagePath: OfflineFolderStructure.getSignatureImagesPath(driverID: driverId, jobID: jobID, pickup: true), type: .signature)
            }
            if !pickup && OfflineFolderStructure.doesDeleteFileExist(driverID: driverId, jobID: jobID) {//only allow dropoff images once the delete file exists
                addImagesToCycle(jobID: jobID, imagePath: OfflineFolderStructure.getExpensesImagesPath(driverID: driverId, jobID: jobID), type: .expense)
                addImagesToCycle(jobID: jobID, imagePath: OfflineFolderStructure.getFleetImagesPath(driverID: driverId, jobID: jobID), type: .fleet)
                addImagesToCycle(jobID: jobID, imagePath: OfflineFolderStructure.getAppraisalImagesPath(driverID: driverId, jobID: jobID, pickup: false), type: .appraisal)
                addImagesToCycle(jobID: jobID, imagePath: OfflineFolderStructure.getSignatureImagesPath(driverID: driverId, jobID: jobID, pickup: false), type: .signature)
            }
        }
        
        
    }
    
    
    fileprivate func addImagesToCycle(jobID : Int, imagePath : String, type : ImageType) {
        
        
        do {
            let imageURLs = try FileManager.default.contentsOfDirectory(at: URL(string:imagePath)!, includingPropertiesForKeys: nil)
            
            for imageURL in imageURLs {
                print(imageURL)
                let object = TemporaryImageObject()
                object.filename = imageURL.lastPathComponent
                object.imageType = type
                object.jobID = jobID
                object.path = imageURL.absoluteString
                currentCycle.append(object)
            }
        }
        catch let error {
            print("addImagesToCycle error: \(error)")
            let exception = NSException(name:NSExceptionName(rawValue: "addImagesToCycle"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }
        
    }
    
    
    func assetUploadResult(path : String, success : Bool) {
        
        if success {
            let fileManager = FileManager.default
            
            do {
                try fileManager.removeItem(at: URL(string:path)!)
            }
            catch {
                let exception = NSException(name:NSExceptionName(rawValue: "assetUploadResult"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
                print("error removing image at path \(path) --> \(error.localizedDescription)")
            }
        }
        checkProgress()
    }
    
    
    func upload() {
     
        let object = currentCycle.first!
        
        switch object.imageType {
        case .some(.appraisal):
            
            Requests.uploadAppraisalImage(jobID: object.jobID, path: object.path, filename: object.filename) { (success) in
                
                self.assetUploadResult(path: object.path, success: success)
            }
        case .some(.expense):
            Requests.uploadExpensesImage(jobID: object.jobID, path: object.path, filename: object.filename) { (success) in
                self.assetUploadResult(path: object.path, success: success)
            }
        case .some(.fleet):
            
            Requests.uploadFleetImage(jobID: object.jobID, path: object.path, filename: object.filename) { (success) in
                self.assetUploadResult(path: object.path, success: success)
            }
        case .some(.signature):
            
            Requests.uploadCustomerSignatureImage(jobID: object.jobID, path: object.path, filename: object.filename) { (success) in
                self.assetUploadResult(path: object.path, success: success)
            }
        default:
            checkProgress()
        }
    }
    
    func checkProgress() {
        self.currentCycle.remove(at: 0)
        if self.currentCycle.count > 0 {
            self.upload()
        }
        else {
            self.inUploadCycle = false
        }
    }
    
    
}
