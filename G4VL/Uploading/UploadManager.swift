//
//  UploadManager.swift
//  G4VL
//
//  Created by Michael Miller on 30/05/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

/*
 Upload manager is used to check for any pending changes. This is the order of tasks
 1. Check for any photos that need to be uploaded
 2. Check for any failed requests that need to be retried
 3. Check for any videos that need to be uploaded
 4. Check for any unread driver messages and show to user
 5. Check for any unapproved wages and show to driver
 6. Delete any local files/folders that have now been pushed
*/


import Foundation
import Bugsnag

class UploadManager : NSObject, PhotoUploadManagerDelegate, VideoUploadManagerDelegate, MessagePopupDelegate {
    
    
    
    static let shared = UploadManager()
    let photoUploadManager : PhotoUploadManager!
    let videoUploadManager : VideoUploadManager!
    var inUploadCycle = false
    var tempQueue : FailedRequests = []
    
    override init() {
        
        photoUploadManager = PhotoUploadManager()
        videoUploadManager = VideoUploadManager()
        
        super.init()
        
        photoUploadManager.delegate = self
        videoUploadManager.delegate = self
    }
    
    func checkForWaitingUploads() {
        
        if inUploadCycle {
            return
        }
        
        inUploadCycle = true
        //photoUploadManager.checkForWaitingUploads()
        
    }
    
    func finishedVideoUploadCycle() {
        
        checkUnreadMessages()
        
        
    }
    
    func checkUnreadMessages() {
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        Requests.getUnreadMessages(driverID: AppManager.sharedInstance.currentUser!.driverID) { (response) in
            if response.errorMessage == nil && response.data != nil {
                
                if let data = response.data {
                    do {
                        let jobsWithMessages = try JSONDecoder().decode(JobsWithMessages.self, from: data)
                        
                        if jobsWithMessages.count > 0 {
                            DispatchQueue.main.async {
                                
                                let currentVC = AppManager.sharedInstance.getTopViewController()
                                if !(currentVC is MessagePopupViewController) {
                                    let sb = UIStoryboard(name: "Message", bundle: nil)
                                    let vc = sb.instantiateViewController(withIdentifier: "message_popup") as! MessagePopupViewController
                                    vc.delegate = self
                                    vc.jobWithUnreadMessages = jobsWithMessages
                                    vc.mode = PopupMode.driverMessages
                                    currentVC.present(vc, animated: true, completion: nil)
                                }
                                
                               
                            }
                        }
                        else {
                            self.finishedCheckingMessages()
                        }
                        
                        
                    }
                    catch let error {
                        let exception = NSException(name:NSExceptionName(rawValue: "checkUnreadMessages"),
                                                    reason:"\(error.localizedDescription)",
                            userInfo:nil)
                        Bugsnag.notify(exception)
                        print("Unread Message Parsing Error: \(error.localizedDescription)")
                        self.finishedCheckingMessages()
                    }
                }
                
            }
        }
    }
    
    func finishedCheckingMessages() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            //the delay is just to make sure the message popup has finished dismissing
            self.checkDriverWages()
        })
        
    }
    
    func checkDriverWages() {
        
        Requests.getUnnapprovedWages() { (response) in
            if response.errorMessage == nil && response.data != nil {
                
                if let data = response.data {
                    do {
                        
                        
                        let wagesToShowDriver : Wages = try JSONDecoder().decode([Wage].self, from: data).filter {
                            return $0.showToDriver == nil || $0.showToDriver! == 1
                        }
                        
                        if wagesToShowDriver.count > 0 {
                            DispatchQueue.main.async {
                                
                                let currentVC = AppManager.sharedInstance.getTopViewController()
                                if !(currentVC is MessagePopupViewController) {
                                    let sb = UIStoryboard(name: "Message", bundle: nil)
                                    let vc = sb.instantiateViewController(withIdentifier: "message_popup") as! MessagePopupViewController
                                    vc.delegate = self
                                    vc.wages = wagesToShowDriver
                                    vc.mode = PopupMode.wages
                                    currentVC.present(vc, animated: true, completion: nil)
                                }
                                else {
                                    self.finishedCheckingDriverWages()
                                }
                                
                            }
                        }
                        else {
                            self.finishedCheckingDriverWages()
                        }
                        
                        
                    }
                    catch let error {
                        print("Wages Parsing Error: \(error.localizedDescription)")
                        let exception = NSException(name:NSExceptionName(rawValue: "checkDriverWages"),
                                                    reason:"\(error.localizedDescription)",
                            userInfo:nil)
                        Bugsnag.notify(exception)
                        self.finishedCheckingDriverWages()
                    }
                }
                
            }
        }
    }
    
    
    func finishedCheckingDriverWages() {
        self.inUploadCycle = false
        OfflineFolderStructure.checkFoldersForDeletion()
    }
    
    
    func finishedPhotoUploadCycle() {
         checkFailedRequestQueue()
    }
    
    
    func checkFailedRequestQueue() {
        tempQueue = getFailedRequests()
//        performRequest()
    }
    
    func performRequest() {
        
        if tempQueue.count > 0 {
            let failedRequest = tempQueue.first!
            guard let _ = AppManager.sharedInstance.currentUser else {
                return
            }
            if failedRequest.driverID != AppManager.sharedInstance.currentUser!.driverID {
                tryNext()
                return
            }
            
            if failedRequest.request == RequestNames.jobStatus.rawValue {
                changeStatus(failedRequest: failedRequest)
                return
            }
            
            if failedRequest.request == RequestNames.appriasal.rawValue {
                pushAppraisal(failedRequest: failedRequest)
                return
            }
            
            if failedRequest.request == RequestNames.expenses.rawValue {
                pushExpenses(failedRequest: failedRequest)
                return
            }
            
            if failedRequest.request == RequestNames.locations.rawValue {
                pushLocations(failedRequest: failedRequest)
                return
            }
            
            if failedRequest.request == RequestNames.markAsRead.rawValue {
                pushMarkAsRead(failedRequest: failedRequest)
                return
            }
            
            if failedRequest.request == RequestNames.wageApproval.rawValue {
                pushWageApproval(failedRequest: failedRequest)
                return
            }
            ///////
            //just incase,
            tryNext()
            //but should never happen as there are no other requests other than above
            //////
        }
        else {
            finishedFailedRequestQueue()
        }
        
    }
    
    
    func tryNext() {
        tempQueue.remove(at: 0)
//        performRequest()
    }
    
    func finishedFailedRequestQueue() {
        videoUploadManager.checkForWaitingUploads()
    }
    
    
    //MARK: Failed Requests
    func addFailedRequest(failedRequest : FailedRequest) {
        var requestQueue = getFailedRequests()
        if !requestQueue.contains(failedRequest) {
            
            
            requestQueue.append(failedRequest)
            saveFailedRequests(queue: requestQueue)
            print("Request added to queue - driver:\(failedRequest.driverID), job:\(failedRequest.jobID ?? -1), request:\(failedRequest.request)")
        }
        
    }
    
    
    func removeFailedRequest(failedRequest : FailedRequest) {
        var requestQueue = getFailedRequests()
        
        if requestQueue.contains(failedRequest) {
            let index = requestQueue.index(of: failedRequest)
            requestQueue.remove(at: index!)
            saveFailedRequests(queue: requestQueue)
            print("Request removed from queue - driver:\(failedRequest.driverID), job:\(failedRequest.jobID ?? -1), request:\(failedRequest.request)")
        }
    }
    
    func getFailedRequests()->FailedRequests {
        if let a = UserDefaults.standard.object(forKey: "FAILED_REQUEST_QUEUE") as? Data  {
            
            do {
                let b = try PropertyListDecoder().decode(FailedRequests.self, from: a)
                return b
            }
            catch {
                let exception = NSException(name:NSExceptionName(rawValue: "getFailedRequests"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
            }
        }
        return []
    }
    
    private func saveFailedRequests(queue:FailedRequests) {
        do {
            
            let data = try PropertyListEncoder().encode(queue)
            UserDefaults.standard.set(data, forKey: "FAILED_REQUEST_QUEUE")
            UserDefaults.standard.synchronize()
        }
        catch {
            print("Could not save video to queue: \(error.localizedDescription)")
            let exception = NSException(name:NSExceptionName(rawValue: "saveFailedRequests"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }
    }
    
    //MARK: Relevant Requests
    
    func changeStatus(failedRequest:FailedRequest) {
        print("RETRYING STATUS UPDATE")
        Requests.changeJobStatusWithCompletion(jobID: failedRequest.jobID!, status: JobStatus(rawValue: failedRequest.status!)!) { (success) in
            if success {
                self.removeFailedRequest(failedRequest: failedRequest)
            }
            self.tryNext()
        }
       
        
    }
    
    func pushAppraisal(failedRequest:FailedRequest) {
        print("RETRYING: Push Appraisal")
        do {
            
            let path = OfflineFolderStructure.getJobPath(driverID: failedRequest.driverID, jobID: failedRequest.jobID!) + "/pod-" + "\(failedRequest.jobID!)" + ".json"
            
            let dataUrl = URL(string:path)!
            
            let data = try Data(contentsOf: dataUrl)
            
            
            Requests.pushAppraisalWithCompletion(jobID: failedRequest.jobID!, appraisal: data) { (success) in
                if success {
                    self.removeFailedRequest(failedRequest: failedRequest)
                    self.tryNext()
                }
                else {
                    //if appraisals fail the queue must be stopped to preserve the appraisal order
                    self.finishedFailedRequestQueue()
                }
                
                
            }
            
        }
        catch {
            let exception = NSException(name:NSExceptionName(rawValue: "pushAppraisal"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            self.tryNext()
        }
        
    }
    
    func pushLocations(failedRequest:FailedRequest) {
        print("RETRYING: Push Locations")
        
        let locations =  try! PropertyListDecoder().decode(Locations.self, from: failedRequest.locations!)
        
        Requests.sendLocationUpdatesWithCompletion(jobID: failedRequest.jobID!, locations: locations) { (success) in
            if success {
                self.removeFailedRequest(failedRequest: failedRequest)
            }
            self.tryNext()
        }
    }
    
    func pushExpenses(failedRequest:FailedRequest) {
        print("RETRYING: Push Expenses")
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        let path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: failedRequest.jobID!) + "/expenses-" + "\(failedRequest.jobID!)" + ".json"
        
        do {
            let dataUrl = URL(string:path)!
            
            let data = try Data(contentsOf: dataUrl)
            
            Requests.pushExpensesWithCompletion(jobID: failedRequest.jobID!, expenses: data) { (success) in
                if success {
                    self.removeFailedRequest(failedRequest: failedRequest)
                }
                self.tryNext()
            }
            
            
        } catch  {
            let exception = NSException(name:NSExceptionName(rawValue: "pushExpenses"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            tryNext()
        }
        
    }
    
    func pushMarkAsRead(failedRequest:FailedRequest) {
        Requests.markAsReadWithCompletion(driverID: failedRequest.driverID, jobID: failedRequest.jobID!, messageID: failedRequest.messageID!) { (success) in
            if success {
                self.removeFailedRequest(failedRequest: failedRequest)
            }
            self.tryNext()
        }
    }
    
    func pushWageApproval(failedRequest:FailedRequest) {
        Requests.actionOnWageWithCompletion(driverID: failedRequest.driverID, wageID: failedRequest.wageID!, approve: failedRequest.approve!, reason: failedRequest.reason!) { (success) in
            if success {
                self.removeFailedRequest(failedRequest: failedRequest)
            }
            self.tryNext()
        }
    }
    
}
extension UIImage {
    
    func textToImage(drawText: NSString, atPoint:CGPoint) -> UIImage? {
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.black
        let textFont: UIFont = UIFont.systemFont(ofSize: 25)//UIFont(name: "Helvetica", size: 25)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(self.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            
            NSAttributedString.Key.backgroundColor:UIColor.white.withAlphaComponent(0.5),
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.strokeColor:UIColor.white,
            NSAttributedString.Key.strokeWidth:-2.0
            ] as [NSAttributedString.Key : Any]
        
        
        let size: CGSize = drawText.size(withAttributes: [NSAttributedString.Key.font: textFont])
        let fontWidth = size.width + 20.0
        
        //Put the image into a rectangle as large as the original image.
        self.draw(in: CGRect(x:0, y:0, width:self.size.width, height: self.size.height))
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRect(x:self.size.width-fontWidth, y:self.size.height-100, width:fontWidth, height:100.0)
        
        //Now Draw the text into an image.
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
}
