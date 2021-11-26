//
//  VideoUploadManager.swift
//  G4VL
//
//  Created by Foamy iMac7 on 05/10/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import SystemConfiguration
import Bugsnag

typealias UploadVideoObjects = [UploadVideoObject]

struct UploadVideoObject: Codable  {
    var jobID = 0
    var driverID = 0
    var path = ""
    var filename = ""
    var uploadLink = ""
    var offSet = 0
    var link = ""
    
    enum CodingKeys: String, CodingKey {
        case jobID = "jobID"
        case driverID = "driverID"
        case path = "path"
        case filename = "filename"
        case uploadLink = "uploadLink"
        case offSet = "offSet"
        case link
    }
}


 class TemporaryVideoObject {
    var jobID = 0
    var path = ""
    var filename = ""
}

protocol VideoUploadManagerDelegate {
    func finishedVideoUploadCycle()
}

class VideoUploadManager: NSObject {

    
    var delegate : VideoUploadManagerDelegate?
    
    var removeFromQueue : [UploadVideoObject] = []
    private var currentCycle : [TemporaryVideoObject] = []
    
    var inUploadCycle = false {
        didSet {
            if !inUploadCycle {
                self.delegate?.finishedVideoUploadCycle()
            }
        }
    }
    
    func checkForWaitingUploads() {
        if inUploadCycle {
            return
        }
        removeFromQueue = []
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
                
                
                for folderURL in folderURLS {
                    let jobID = (folderURL.lastPathComponent.replacingOccurrences(of: "job_", with: "") as NSString).integerValue
                    
                    
                    if OfflineFolderStructure.doesPodFileExist(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID) {
                        //pod has been submitted, check for images and upload
                        let videosPath = OfflineFolderStructure.getVideoPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID, pickup: true)
                        let videoURLs = try fileManager.contentsOfDirectory(at: URL(string:videosPath)!, includingPropertiesForKeys: nil)
                        
                        for videoURL in videoURLs {
                            let object = TemporaryVideoObject()
                            object.filename = videoURL.lastPathComponent
                            object.jobID = jobID
                            object.path = videoURL.absoluteString
                            currentCycle.append(object)
                        }
                    }
                    
                    
                }
                
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
            inUploadCycle = false
            let exception = NSException(name:NSExceptionName(rawValue: "checkForWaitingUploads"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }
        */
        
    }
    
    
    func upload() {
        
        if isInternetAvailable() {
        
            let object = currentCycle.first!
            
            do {
                let videoData = try Data(contentsOf: URL(string:object.path)!)
                
                if let startedVideo = getVideoObjectFromQueue(object: object) {
                    print("Video has started upload")
                    checkUploadProgress(object: startedVideo, videoData: videoData)
                }
                else {
                    //Step 1
                    print("Video NOT Started upload")
                    createVideoOnVimeo(object: object, videoData: videoData)
                }
                
                
            } catch  {
                let exception = NSException(name:NSExceptionName(rawValue: "upload"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
                print("Error Starting Upload (catch): \(error.localizedDescription)")
                tryNext()
            }
        
        }
        else {
            tryNext()
        }
        
    }
    
    func createVideoOnVimeo(object: TemporaryVideoObject, videoData:Data) {
        
        var urlRequest = URLRequest(url: URL(string:Vimeo.UPLOAD_VIDEO)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(Vimeo.VIMEO_ACCES_TOKEN)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/vnd.vimeo.*+json;version=3.4", forHTTPHeaderField: "Accept")
        
        let body : [String:Any] = [
            "upload" : [
                "approach" : "tus",
                "size" : videoData.count,
            ]
        ]
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted) as Data
            urlRequest.httpBody = bodyData
            
            
            URLSession.shared.dataTask(with: urlRequest) {
                data, response, err in
                DispatchQueue.main.async {
                    if err != nil {
                        print("Error Starting Upload: \(err!.localizedDescription)")
                        self.tryNext()
                    }
                    else {
                        
                        let httpResponse = response as! HTTPURLResponse
                        
                        if httpResponse.statusCode == 200
                        {
                            
                            do {
                                let parsedJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                                
                                let upload = parsedJson["upload"] as! [String:Any]
                                let uploadLink = upload["upload_link"] as! String
                                let link = parsedJson["link"] as! String
                                guard let _ = AppManager.sharedInstance.currentUser else {
                                    return
                                }
                                var uploadVideoObject = UploadVideoObject()
                                uploadVideoObject.driverID = AppManager.sharedInstance.currentUser!.driverID
                                uploadVideoObject.filename = object.filename
                                uploadVideoObject.jobID = object.jobID
                                uploadVideoObject.path = object.path
                                uploadVideoObject.offSet = 0
                                uploadVideoObject.uploadLink = uploadLink
                                uploadVideoObject.link = link
                                
                                //Save to userdefaults
                                var queue = self.getVideoQueue()
                                queue.append(uploadVideoObject)
                                self.saveQueue(queue: queue)
                                
                                self.checkUploadProgress(object: uploadVideoObject, videoData: videoData)
                                
                                
                            }
                            catch {
                                let exception = NSException(name:NSExceptionName(rawValue: "createVideoOnVimeo"),
                                                            reason:"\(error.localizedDescription)",
                                    userInfo:nil)
                                Bugsnag.notify(exception)
                                self.tryNext()
                                
                            }
                            
                        }
                        else
                        {
                            print("Creating Video Status Code: \(httpResponse.statusCode)")
                            self.tryNext()
                        }
                    }
                }
                
                
                }.resume()
        } catch  {
            let exception = NSException(name:NSExceptionName(rawValue: "createVideoOnVimeo"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print("Error Starting Upload (catch): \(error.localizedDescription)")
            tryNext()
        }
    }
    
    
    func checkUploadProgress(object : UploadVideoObject, videoData : Data) {
        //get the number of bytes uploaded so far
        
        var urlRequest = URLRequest(url: URL(string:object.uploadLink)!)
        
        urlRequest.httpMethod = "HEAD"
        urlRequest.setValue("Bearer \(Vimeo.VIMEO_ACCES_TOKEN)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("1.0.0", forHTTPHeaderField: "Tus-Resumable")

        
        URLSession.shared.dataTask(with: urlRequest) {
            data, response, err in
            DispatchQueue.main.async {
                if err != nil {
                    print("Error Starting Upload: \(err!.localizedDescription)")
                    self.tryNext()
                }
                else {
                    
                    let httpResponse = response as! HTTPURLResponse
                    
                    if httpResponse.statusCode == 200
                    {
                        
                        let headers = httpResponse.allHeaderFields
                        
                      
                        let uploadeOffSet = (headers["upload-offset"] as! NSString).integerValue
                        let uploadLength = (headers["upload-length"] as! NSString).integerValue
                        
                        if uploadeOffSet == uploadLength {
                            print("VIDEO UPLOADED")
                            self.removeFromQueue.append(object)
                            self.tryNext()
                        }
                        else {
                            print("RESUMING UPLOAD")
                            self.resumeUpload(fromBytes: uploadeOffSet, videoData: videoData, object: object)
                        }
                        
                    }
                    else
                    {
                        print("Checking Video Progress Status Code: \(httpResponse.statusCode)")
                        self.tryNext()
                    }
                }
            }
            
            
            }.resume()
        
    }
    
    func resumeUpload(fromBytes:Int, videoData : Data, object:UploadVideoObject) {
        
        var urlRequest = URLRequest(url: URL(string:object.uploadLink)!)
        
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("Bearer \(Vimeo.VIMEO_ACCES_TOKEN)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("1.0.0", forHTTPHeaderField: "Tus-Resumable")
        urlRequest.setValue("\(fromBytes)", forHTTPHeaderField:"Upload-Offset" )
        urlRequest.setValue("application/offset+octet-stream", forHTTPHeaderField: "Content-Type")
        
        
        urlRequest.httpBody = videoData
        
        
        URLSession.shared.dataTask(with: urlRequest) {
            data, response, err in
            if err != nil {
                print("Error Starting Upload: \(err!.localizedDescription)")
                self.tryNext()
            }
            else {
                
                let httpResponse = response as! HTTPURLResponse
                
                if httpResponse.statusCode / 100 == 2
                {
                 
                    self.checkUploadProgress(object: object, videoData: videoData)
                    
                }
                else
                {
                    print("Uploading Video Status Code: \(httpResponse.statusCode)")
                    self.tryNext()
                }
            }
            
            }.resume()
        
    }
    
  
    
    func tryNext() {
        
        self.currentCycle.remove(at: 0)
        if self.currentCycle.count > 0 {
            self.upload()
        }
        else {
            removeUploaded()
        }
    }
    
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    
    //MARK: QUEUE
    
    func removeUploaded() {
        
        if removeFromQueue.count > 0 {
            guard let _ = AppManager.sharedInstance.currentUser else {
                return
            }
            //1.  get only current driver jobs
            removeFromQueue = removeFromQueue.filter {
                return $0.driverID == AppManager.sharedInstance.currentUser!.driverID
            }
            
            //2. Put videos from same job together in dictionary
            //format will be
            //  [
            //    "JOB_ID_HERE":
            //    [
            //        UploadVideoObject,
            //        UploadVideoObject
            //    ],
            //    "JOB_ID_HERE":
            //    [
            //        UploadVideoObject,
            //        UploadVideoObject
            //    ]
            //]
            var dictionaryOfJobs : [String:[UploadVideoObject]] = [:]
            
            for obj in removeFromQueue {
                if dictionaryOfJobs.keys.contains("\(obj.jobID)") {
                    //this id already exists in the dictionary
                    dictionaryOfJobs["\(obj.jobID)"]!.append(obj)
                }
                else {
                    //add the new job id to dictionary
                    dictionaryOfJobs["\(obj.jobID)"] = [obj]
                    
                }
            }
            
            var counter = dictionaryOfJobs.count
            
            //3. Save the vimeo links to video appraisal
            guard let _ = AppManager.sharedInstance.currentUser else {
                return
            }
            //Loop through the jobs
            for job in dictionaryOfJobs {
                
                do {
                    //get the existing appraisal
                    let path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: Int(job.key)!) + "/job-appraisal" + "\(job.key)" + ".json"
                    
                    let data = try Data(contentsOf: URL(string:path)!)
                    
                    
                    let jobToChange = try JSONDecoder().decode(JobAppraisal.self, from: data)
                    
                    
                    //loop through video objects
                    for videoObject in job.value {
                        //get video with same filename
                        var results = jobToChange.videoAppraisal!.pickup.videos.filter {
                            return $0.videoName! == videoObject.filename
                        }
                        if results.count == 0 {
                            results = jobToChange.videoAppraisal!.dropoff.videos.filter {
                                return $0.videoName! == videoObject.filename
                            }
                        }
                        if results.count > 0 {
                            //change video vimeo link and save job
                            let video = results.first!
                            video.vimeoLink = videoObject.link
                            print("Saved Vimeo Link: \(videoObject.link)")
                            
                        }
                    }
                    //save job locally
                    JobsManager.saveJobAppraisal(job: jobToChange, saveExpenses: false)
                    
                    //4. Delete videos from queue and storage
                    deleteVideoObjectsFromQueue(objects: job.value)
                    deleteVideosFromFileStorage(objects: job.value)
                    
                    //5. Generate the PODs again and push appraisal
                    JobsManager.generatePODSFile(job: jobToChange) { (url, error) in
                        
                        if url != nil {
                            do {
                                let data = try Data(contentsOf: url!)
                                Requests.pushAppraisalWithCompletion(jobID: jobToChange.jobID!, appraisal: data, completion: { (success) in
                                    print(success)
                                })
                                //Requests.pushAppraisal(jobID: jobToChange.jobID!, appraisal: data)
                            }
                            catch {
                                let exception = NSException(name:NSExceptionName(rawValue: "generatePODSFile"),
                                                            reason:"\(error.localizedDescription)",
                                    userInfo:nil)
                                Bugsnag.notify(exception)
                            }
                        }
                        else {
                            //add to a push queue
                        }
                        counter -= 1
                    }
                    
                }
                catch {
                    counter -= 1
                    let exception = NSException(name:NSExceptionName(rawValue: "generatePODSFile"),
                                                reason:"\(error.localizedDescription)",
                        userInfo:nil)
                    Bugsnag.notify(exception)
                    continue
                    
                }
                
               
                
            }
            
            if counter <= 0 {
                removeFromQueue = []
                self.inUploadCycle = false
            }
            
        }
        else {
            
            removeFromQueue = []
            self.inUploadCycle = false
        }
        
    }
    
    func deleteVideosFromFileStorage(objects:[UploadVideoObject]) {
        let fileManager = FileManager.default
        
        for object in objects {
            do {
                try fileManager.removeItem(at: URL(string:object.path)!)
                print("removed video locally")
            }
            catch {
                let exception = NSException(name:NSExceptionName(rawValue: "deleteVideosFromFileStorage"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
                print("error removing video at path \(object.path) --> \(error.localizedDescription)")
            }
        }
        
    }
    
    func deleteVideoObjectsFromQueue(objects:[UploadVideoObject]) {
        var queue = getVideoQueue()
        
        for object in objects {
            queue = queue.filter {
                return $0.driverID != object.driverID && $0.jobID != object.jobID
            }
        }
        print("removed video from queue")
        saveQueue(queue: queue)
    }
    
    
    func getVideoQueue() -> [UploadVideoObject] {
        if let a = UserDefaults.standard.object(forKey: "VIDEO_QUEUE") as? Data  {
            
            do {
                let b = try PropertyListDecoder().decode(UploadVideoObjects.self, from: a)
                return b
            }
            catch {
                let exception = NSException(name:NSExceptionName(rawValue: "getVideoQueue"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
            }
        }
        return []
    }
    
    func saveQueue(queue:[UploadVideoObject]) {
        do {
            let data = try PropertyListEncoder().encode(queue)
            UserDefaults.standard.set(data, forKey: "VIDEO_QUEUE")
            UserDefaults.standard.synchronize()
        }
        catch {
            let exception = NSException(name:NSExceptionName(rawValue: "saveQueue"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print("Could not save video to queue: \(error.localizedDescription)")
        }
        
    }
    
    
    func getVideoObjectFromQueue(object : TemporaryVideoObject) -> UploadVideoObject? {
        let queue = getVideoQueue()
        
        let result = queue.filter {
            return $0.jobID == object.jobID && $0.driverID == AppManager.sharedInstance.currentUser!.driverID!
            
        }
        
        if result.count > 0 {
            return result.first
        }
        return nil
    }
}








