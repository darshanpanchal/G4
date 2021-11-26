//
//  OfflineFolderStructure.swift
//  G4VL
//
//  Created by Foamy iMac7 on 22/02/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit
import Bugsnag

class OfflineFolderStructure: NSObject {

    
    //The basis of the folder structure
    /*
     {driver_id} [
            {job_id} [
                pod.json
                job_appraisal.json
                appraisal_images [
                        pickup [
                            guid.jpg,
                            guid.jpg
                        ],
                         dropoff [
                            guid.jpg,
                            guid.jpg
                         ]
     
                ]
                expenses_images [
                        guid.jpg
                ]
                signature_images [
                         pickup [
                            guid.jpg
                         ],
                         dropoff [
                            guid.jpg
                         ]
                ]
                fleet_images [
                        guid.jpg
                ]
                videos [
                         pickup [
                            guid.mp4
                         ],
                         dropoff [
                            guid.mp4
                         ]
                ]
            ]
     ]
     */
    
    static func getDriverPath(id:Int) -> String {
        let documentsPath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        /*let path = "file://\(documentsPath)/driver_\(id)"
        let updatePath = "file://\(documentsPath)/driver_\(id)_DoNotFound"
        let filePath = path.replacingOccurrences(of: "file://", with: "")
        if FileManager().fileExists(atPath: filePath){
            try FileManager.default.moveItem(at: path, to: destinationPath)
        }*/
        return "file://\(documentsPath)/driver_\(id)"
    }
    static func getLocationPath()->String{
        let documentsPath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return "file://\(documentsPath)/Locations"
    }
    
    static func getJobPath(driverID:Int, jobID:Int) -> String {
        return getDriverPath(id:driverID) + "/job_\(jobID)"
    }
    
    static func getAppraisalImagesPath(driverID:Int, jobID:Int, pickup : Bool) -> String {
        return getJobPath(driverID:driverID, jobID:jobID) + "/appraisal_images" + (pickup ? "/pickup" : "/dropoff")
    }
    
    static func getExpensesImagesPath(driverID:Int, jobID:Int) -> String {
        return getJobPath(driverID:driverID, jobID:jobID) + "/expense_images"
    }
    
    static func getSignatureImagesPath(driverID:Int, jobID:Int, pickup : Bool) -> String {
        return getJobPath(driverID:driverID, jobID:jobID) + "/signature_image" + (pickup ? "/pickup" : "/dropoff")
    }
    
    static func getFleetImagesPath(driverID:Int, jobID:Int) -> String {
        return  getJobPath(driverID:driverID, jobID:jobID) + "/fleet_images"
    }
    
    static func getVideoPath(driverID:Int, jobID:Int, pickup : Bool) -> String {
        return  getJobPath(driverID:driverID, jobID:jobID) + "/videos"  + (pickup ? "/pickup" : "/dropoff")
    }
    
    static func doesPodFileExist(driverID:Int, jobID:Int) -> Bool {
        return doesFileExist(path:  getJobPath(driverID:driverID, jobID:jobID) + "/pod-\(jobID).json")
    }
    
    static func doesDeleteFileExist(driverID:Int, jobID:Int) -> Bool {
        return doesFileExist(path:  getJobPath(driverID:driverID, jobID:jobID) + "/delete.txt")
    }
    
    static func anyImagesOrVideos(driverID:Int, jobID:Int) -> Bool {
        guard let _ = AppManager.sharedInstance.currentUser else {
            return  false
        }
        print(isNotEmptyFolder(path: OfflineFolderStructure.getAppraisalImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup: true)))
        print( isNotEmptyFolder(path: OfflineFolderStructure.getAppraisalImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup: false)))
        print(isNotEmptyFolder(path: OfflineFolderStructure.getExpensesImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID)))
        print(isNotEmptyFolder(path: OfflineFolderStructure.getFleetImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID)))
        print(isNotEmptyFolder(path: OfflineFolderStructure.getSignatureImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup: true)))
        print( isNotEmptyFolder(path: OfflineFolderStructure.getSignatureImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup: false)))
        print(isNotEmptyFolder(path: OfflineFolderStructure.getVideoPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup:true)))
        print(isNotEmptyFolder(path: OfflineFolderStructure.getVideoPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup:false)))
        
        return isNotEmptyFolder(path: OfflineFolderStructure.getAppraisalImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup: true)) ||
            isNotEmptyFolder(path: OfflineFolderStructure.getAppraisalImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup: false)) ||
            isNotEmptyFolder(path: OfflineFolderStructure.getExpensesImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID)) ||
            isNotEmptyFolder(path: OfflineFolderStructure.getFleetImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID)) ||
            isNotEmptyFolder(path: OfflineFolderStructure.getSignatureImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup: true)) ||
            isNotEmptyFolder(path: OfflineFolderStructure.getSignatureImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup: false)) ||
            isNotEmptyFolder(path: OfflineFolderStructure.getVideoPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup:true)) ||
            isNotEmptyFolder(path: OfflineFolderStructure.getVideoPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup:false))
        
        
    }
    
    static func isNotEmptyFolder(path:String) -> Bool {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: URL(string:path)!, includingPropertiesForKeys: nil)
            return urls.count > 0
        }
        catch let error {
            let exception = NSException(name:NSExceptionName(rawValue: "isNotEmptyFolder"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print("isNotEmptyFolder error: \(error)")
            return true
        }
    }
   
    
    static func createRequiredFolders(driverID:Int, jobID:Int) {
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        let am = AppManager.sharedInstance
        
        let paths = [
            getDriverPath(id: driverID),
            getJobPath(driverID: am.currentUser!.driverID!, jobID: jobID),
            getVideoPath(driverID: am.currentUser!.driverID!, jobID: jobID, pickup: true),
            getVideoPath(driverID: am.currentUser!.driverID!, jobID: jobID, pickup: false),
            getAppraisalImagesPath(driverID: am.currentUser!.driverID!, jobID: jobID,pickup: true),
            getAppraisalImagesPath(driverID: am.currentUser!.driverID!, jobID: jobID,pickup: false),
            getExpensesImagesPath(driverID: am.currentUser!.driverID!, jobID: jobID),
            getSignatureImagesPath(driverID: am.currentUser!.driverID!, jobID: jobID, pickup: true),
            getSignatureImagesPath(driverID: am.currentUser!.driverID!, jobID: jobID, pickup: false),
            getFleetImagesPath(driverID: am.currentUser!.driverID!, jobID: jobID)
        ]
        
        
        for path in paths {
            if !doesFolderExist(path:path) {
                createFolder(named: path)
            }
        }
        
        
    }
    
    
    static func doesFolderExist(path:String) -> Bool {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        if fileManager.fileExists(atPath: path, isDirectory:&isDir) {
            if !isDir.boolValue {
                // file exists and is not a directory
                return false
            }
            else {
                //file exists and is a driectory
                return true
        
            }
        }
        else {
            // file does not exist
            return false
        }
    }
    
    static func doesFileExist(path:String) -> Bool {
        
        if let url = URL.init(string: path){//URL(fileURLWithPath: path)
            let filePath = url.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                return true
            } else {
                return false
            }
        }else{
             return false
        }
    }
    
    
    static func containsChildern(path:String) -> Bool {
        // Get the directory contents urls (including subfolders urls)
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: URL(string:path)!, includingPropertiesForKeys: nil, options: [])
        return directoryContents.count < 0
    }
    
    static func getLatestLocalCurrentJob() -> Job? {
        
        
        
        return nil
    }
    
    
    static func createFolder(named : String) {
        
        //createDirectory(atPath: cannot deal with the "file://" prefix
        let pathWithoutFilePrefix = named.replacingOccurrences(of: "file://", with: "")
        
        do {
            try FileManager.default.createDirectory(atPath: pathWithoutFilePrefix, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            let exception = NSException(name:NSExceptionName(rawValue: "createFolder"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print("ERRORORORR \(error.localizedDescription)");
        }
    }
    
    static func checkFoldersForDeletion() {
        //job folders can only be deleted once there is a "delete.txt" file present (indicates job finished)
        //And no videos or images exist in the folder (all assets uploaded)
        //And no failed requests relating to this job id are waiting in the failed requests queue (no awaiting api changes)
        
        
        print("Checking for deletion")
        
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        
        
        let path = OfflineFolderStructure.getDriverPath(id: AppManager.sharedInstance.currentUser!.driverID!)
        
        let fileManager = FileManager.default
        do {
            let folderURLS = try fileManager.contentsOfDirectory(at: URL(string:path)!, includingPropertiesForKeys: nil)
            
            if folderURLS.count > 0 {
                
                for folderURL in folderURLS {
                    
                    let jobID = (folderURL.lastPathComponent.replacingOccurrences(of: "job_", with: "") as NSString).integerValue
                    
                    if doesDeleteFileExist(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID) {print("Delete file exists")
                        if anyImagesOrVideos(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID) {print("Assets still exist")
                            continue
                        }else {
                            let queue = UploadManager.shared.getFailedRequests()
                            let results = queue.filter {
                                return $0.driverID == AppManager.sharedInstance.currentUser!.driverID && $0.jobID == jobID
                            }
                            
                            if results.count == 0 {print("Removing Folder")
                                //Can delete
                                //Change job status to complete, instead of completeAwaitingData
                                //JSON push appraisal on success continue
                                
                                Requests.changeJobStatusWithCompletion(jobID: jobID, status: .completed) { (success) in
                                    if success {
                                        
                                        guard let _ = AppManager.sharedInstance.currentUser else {
                                            return
                                        }
                                        guard let _ = AppManager.sharedInstance.currentJobAppraisal else {
                                            return
                                        }
                                        AppManager.sharedInstance.currentJobAppraisal!.status = .completed
                                        JobsManager.generatePODSFile(job: AppManager.sharedInstance.currentJobAppraisal!, completion: {
                                            (url, error) in
                                            
                                            if url != nil {
                                                
                                                do {
                                                    let data = try Data(contentsOf: url!)
                                                    Requests.pushAppraisalWithCompletion(jobID: AppManager.sharedInstance.currentJobAppraisal!.jobID!, appraisal: data, completion: { (success) in
                                                        if success{
                                                            deleteFolder(path: folderURL.absoluteString.trimmingCharacters(in: .punctuationCharacters))
                                                        }
                                                    })
                                                    //Requests.pushAppraisal(jobID:AppManager.sharedInstance.currentJobAppraisal!.jobID!, appraisal: data)
                                                }
                                                catch {
                                                    let exception = NSException(name:NSExceptionName(rawValue: "checkFoldersForDeletion"),
                                                                                reason:"\(error.localizedDescription)",
                                                        userInfo:nil)
                                                    Bugsnag.notify(exception)
                                                }
                                            }
                                            
                                        })
                                        /*
                                         let path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: job.jobID!) + "/pod-" + "\(job.jobID!)" + ".json"
                                        
                                        let path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: AppManager.sharedInstance.currentJobAppraisal!.jobID!)
 
                                        //push appraisal
                                        if let dataUrl = URL(string:path){
                                            self.pushAppraisal(folderURl:folderURL,dataURl: dataUrl, jobID: jobID)
                                        }
                                            */
                                        //let data = try Data(contentsOf: dataUrl)
//                                        print(folderURL.absoluteString)
//                                        deleteFolder(path: folderURL.absoluteString.trimmingCharacters(in: .punctuationCharacters))
                                       
                                    }
                                }
                                
                                
                            }
                            else {
                                print("Still data to be pushed")
                                continue
                            }
                        }
                    }
                    else {
                        continue
                    }
                }
                
            }
            else {
                print("No Folders Exist")
            }
        } catch {
            let exception = NSException(name:NSExceptionName(rawValue: "checkFoldersForDeletion"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }
    }
    static private func pushAppraisal(folderURl:URL,dataURl:URL,jobID:Int){
        do{
            let data = try Data(contentsOf: dataURl)
            Requests.pushAppraisalWithCompletion(jobID: jobID, appraisal: data) { (success) in
                if success {
                    print(folderURl.absoluteString)
                    deleteFolder(path: folderURl.absoluteString.trimmingCharacters(in: .punctuationCharacters))
                }else {
                    
                }
            }
        }catch{
            let exception = NSException(name:NSExceptionName(rawValue: "pushAppraisal"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }

    }
   static private func deleteFolder(path:String) {
    
    
    
        let fm = FileManager.default
        
        
        do {
            try fm.removeItem(at: URL(string:path)!)
            print("Deleted Folder: \(path)")
        }
        catch let error {
            print("Error Deleting Job Folder: \(error.localizedDescription)")
            let exception = NSException(name:NSExceptionName(rawValue: "pushAppraisal"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }
    }
    
    
}
