//
//  Requests.swift
//  G4VL
//
//  Created by Michael Miller on 07/03/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit
import Uploadcare
import Bugsnag



class Requests: NSObject {

    enum Method : String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
    }
    static var jobAppraisal : JobAppraisal {
        return AppManager.sharedInstance.currentJobAppraisal!
    }
    //MARK: LOGIN
    
    public static func loginUser(email:String, password:String, completion:@escaping (_:ApiResult)->()) {
        
        let body =  "email=\(email)&" + "password=\(password)"
        let url = URL(string:ApiConstants.Login.endPoint)!
        
        #if DEBUG
            print("\n------------------------------")
            print("Login URL: \(url)")
            print("Body: \(body)")
            print("------------------------------\n")
        #endif
        
        let request = basicRequest(url: url, method: Method.post.rawValue, body: body, accessToken: nil)
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            completion(apiResult)
        }
        /*
        Response.basic(urlRequest: request) { (apiResult) in
            completion(apiResult)
        }*/
    }
    
    
    //MARK: JOBS
    
    public static func getAllJobs(completion:@escaping (_ : ApiResult)->()) {
        
        let url = URL(string:ApiConstants.Job.endpoint)!
        let request = basicRequest(url: url, method: Method.get.rawValue, body: nil, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        #if DEBUG
            print("\n------------------------------")
            print("All jobs URL: \(url)")
            print("------------------------------\n")
        #endif
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            completion(apiResult)
        }
//        Response.basic(urlRequest: request) { (apiResult) in
//            completion(apiResult)
//        }
    }
    //GET Expense Trail
    public static func getAllJobsExpenseTrail(startDate:String,endDate:String,completion:@escaping (_ : ApiResult)->()) {
        
        let url = URL(string:ApiConstants.ExpensesTrail.getEndpoint(userid: AppManager.sharedInstance.currentUser!.driverID, startDate: startDate, endDate: endDate))!
        
        let request = basicRequest(url: url, method: Method.get.rawValue, body: nil, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        #if DEBUG
        print("\n------------------------------")
        print("All jobs URL: \(url)")
        print("------------------------------\n")
        #endif
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            completion(apiResult)
        }
        //        Response.basic(urlRequest: request) { (apiResult) in
        //            completion(apiResult)
        //        }
    }
    //GET Wages Download URL
    public static func getWagesDownloadURL(wagesID:String,completion:@escaping (_ : ApiResult)->()) {
           
            let url = URL(string:ApiConstants.WagesBreakDownURL.getEndpoint(wagesID:"\(wagesID)"))!
           
           let request = basicRequest(url: url, method: Method.get.rawValue, body: nil, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
           
           #if DEBUG
           print("\n------------------------------")
           print("WagesBreakDown URL: \(url)")
           print("------------------------------\n")
           #endif
           Response.shared.basicNew(urlRequest: request) { (apiResult) in
               completion(apiResult)
           }
           //        Response.basic(urlRequest: request) { (apiResult) in
           //            completion(apiResult)
           //        }
       }
    
    public static func changeJobStatusWithSplit(jobID : Int, status:JobStatus,isaccept:Bool) {
        
        
        let url = URL(string:ApiConstants.JobStatus.getEndpoint(id: jobID))!
        
        let body = "\(ApiConstants.Job.ResConst.status)=\(status.rawValue)&" + "damage_approval_driver_2=\(isaccept)"
        
        #if DEBUG
        print("\n------------------------------")
        print("Change Job Status URL: \(url)")
        print("Body: \(body)")
        print("------------------------------\n")
        #endif
        
        let request = basicRequest(url: url, method: Method.post.rawValue, body: body, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            if apiResult.statusCode != nil && (apiResult.statusCode == 200 || apiResult.statusCode == 400)  {
                //400 means for example the job has now been cancelled/declined
                
            }
            else {
                UploadManager.shared.addFailedRequest(failedRequest: FailedRequest(driverID: AppManager.sharedInstance.currentUser!.driverID, jobID: jobID, messageID: nil, wageID: nil, approve: nil, reason: nil, request: RequestNames.jobStatus.rawValue, status: status.rawValue, locations: nil))
            }
        }
    }
    public static func changeJobStatus(jobID : Int, status:JobStatus) {
        
        
        let url = URL(string:ApiConstants.JobStatus.getEndpoint(id: jobID))!
        let body = "\(ApiConstants.Job.ResConst.status)=\(status.rawValue)"
        
        #if DEBUG
            print("\n------------------------------")
            print("Change Job Status URL: \(url)")
            print("Body: \(body)")
            print("------------------------------\n")
        #endif
        
        let request = basicRequest(url: url, method: Method.post.rawValue, body: body, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            if apiResult.statusCode != nil && (apiResult.statusCode == 200 || apiResult.statusCode == 400)  {
                //400 means for example the job has now been cancelled/declined
                
            }
            else {
                UploadManager.shared.addFailedRequest(failedRequest: FailedRequest(driverID: AppManager.sharedInstance.currentUser!.driverID, jobID: jobID, messageID: nil, wageID: nil, approve: nil, reason: nil, request: RequestNames.jobStatus.rawValue, status: status.rawValue, locations: nil))
            }
        }
    }
    
    public static func changeJobStatusWithCompletion(jobID : Int, status:JobStatus, completion:@escaping (Bool)->()) {
        
        let url = URL(string:ApiConstants.JobStatus.getEndpoint(id: jobID))!
        let body = "\(ApiConstants.Job.ResConst.status)=\(status.rawValue)"
        
        #if DEBUG
        print("\n------------------------------")
        print("Change Job Status URL: \(url)")
        print("Body: \(body)")
        print("------------------------------\n")
        #endif
        
        let request = basicRequest(url: url, method: Method.post.rawValue, body: body, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            if apiResult.statusCode != nil && (apiResult.statusCode == 200 || apiResult.statusCode == 400)  {
                //400 means for example the job has now been cancelled/declined
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    
    public static func pushAppraisal(jobID : Int, appraisal:Data) {
        
        let url = URL(string:ApiConstants.Appraisal.getEndpoint(id: jobID))!
        
        let body =  appraisal
        
        #if DEBUG
            print("\n------------------------------")
            print("Push Appraisal URL: \(url)")
            print("Body: \(body)")
            print("------------------------------\n")
        #endif
        
        
//
//        var request = basicRequest(url: url, method: Method.post.rawValue, body: body, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
//
//
//
//        request.setValue("text/json", forHTTPHeaderField: "Content-Type")
//
        UploadManager.shared.addFailedRequest(failedRequest: FailedRequest(driverID: AppManager.sharedInstance.currentUser!.driverID, jobID: jobID, messageID: nil, wageID: nil, approve: nil, reason: nil, request: RequestNames.appriasal.rawValue, status: nil, locations: nil))
        
        UploadManager.shared.checkForWaitingUploads()
        
//        Response.basic(urlRequest: request) { (apiResult) in
//            if apiResult.statusCode != nil && apiResult.statusCode == 200 {
//
//            }
//            else {
//
//                UploadManager.shared.addFailedRequest(failedRequest: FailedRequest(driverID: AppManager.sharedInstance.currentUser!.driverID, jobID: jobID, messageID: nil, wageID: nil, approve: nil, reason: nil, request: RequestNames.appriasal.rawValue, status: nil, locations: nil))
//            }
//        }
    }
    
    public static func pushAppraisalWithCompletion(jobID : Int, appraisal:Data, completion:@escaping (Bool)->()) {
        DispatchQueue.main.async {
            ProgressHud.show()
        }
        let url = URL(string:ApiConstants.Appraisal.getEndpoint(id: jobID))!
        
        let body =  appraisal
        
        #if DEBUG
        print("\n------------------------------")
        print("Push Appraisal URL: \(url)")
        print("Body: \(body)")
        print("------------------------------\n")
        #endif
        
        
        
        var request = basicRequest(url: url, method: Method.post.rawValue, body: body, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        request.setValue("text/json", forHTTPHeaderField: "Content-Type")
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if apiResult.statusCode != nil && apiResult.statusCode == 200 {
                completion(true)
            }
            else {
                completion(false)
            }
        }
        
        
    }
    
    //MARK: GEOLocation
    public static func savedLocationToJsonFile(){
        
    }
    
    public static func sendLocationUpdates(jobID : Int, locations:Locations) {
        
        
        let url = URL(string:ApiConstants.Geolocations.getEndpoint(id: jobID))!
        var jsonObject:[String:Any] =  [:]
        jsonObject["geolocations"] = toSerializedObject(locations: locations,jobID : jobID)
        print(jsonObject)
        let json = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        
        #if DEBUG
            print("\n------------------------------")
            print("Send Geolocations URL: \(url)")
            print("JSON: \(String(data:json, encoding:.utf8)!)")
            print("------------------------------\n")
        #endif

        let body =  json
        
        var request = basicRequest(url: url, method: Method.post.rawValue, body: body, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        request.setValue("text/json", forHTTPHeaderField: "Content-Type")
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            if apiResult.statusCode != nil && apiResult.statusCode == 200 {
                                
            }else {
               let data = try! PropertyListEncoder().encode(locations)
               self.saveLocation(jsonData: data)
                /*
                UploadManager.shared.addFailedRequest(failedRequest: FailedRequest(driverID: AppManager.sharedInstance.currentUser!.driverID, jobID: jobID, messageID: nil, wageID: nil, approve: nil, reason: nil, request: RequestNames.locations.rawValue, status: nil, locations: data))*/
            }
        }
    }
    
    static func toSerializedObject(locations:Locations,jobID : Int)->[[String:String]] {
        
        
        var locationsObj : [[String:String]] = []
        
        for l in locations {
            let locationObj : [String:String] = [
                "latt":l.latt,
                "long":l.long,
                "geolocated_at":l.geoLocatedAt,
                "job_id":"\(jobID)"
            ]
            locationsObj.append(locationObj)
        }
        if let currentLocationJSON = self.getCurrentLocationFromDeviceStorage(),let currentLocationArray = currentLocationJSON["geolocations"] as? [[String:String]]{
            locationsObj.append(contentsOf: currentLocationArray)
            
        }
        return locationsObj
        
    }
    static func getCurrentLocationFromDeviceStorage()->[String:Any]?{
        let path = OfflineFolderStructure.getLocationPath()+"/locations.json"
        let filepath = path.replacingOccurrences(of: "file://", with: "")
        guard FileManager().fileExists(atPath: filepath) else{
            return nil
        }
        do {
        
            let data = try Data(contentsOf: URL(string:path)!)
            let locationsArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]
            return locationsArray
        } catch  {
            let _ = NSException(name:NSExceptionName(rawValue: "getCurrentLocationFromDeviceStorage"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
           // Bugsnag.notify(exception)
            print ("JSON Save Failure: \(error.localizedDescription)");
        }
        return nil
    }
    static func saveLocation(jsonData:Data){
        
        //////////Create the folder paths, if not already created
        OfflineFolderStructure.createFolder(named:OfflineFolderStructure.getLocationPath())
        ///////////
        do {
            let path = OfflineFolderStructure.getLocationPath()+"/locations.json"
            
            try jsonData.write(to: URL(string:path)!, options: .atomicWrite)
            print("JSON SAVED: Location")
            let data = try Data(contentsOf: URL(string:path)!)
            let _ = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]
            
        } catch  {
            let exception = NSException(name:NSExceptionName(rawValue: "saveLocation"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print ("JSON Save Failure: \(error.localizedDescription)");
        }
    }
    
    public static func sendLocationUpdatesWithCompletion(jobID : Int, locations:Locations, completion:@escaping (Bool)->()) {
        
        let url = URL(string:ApiConstants.Geolocations.getEndpoint(id: jobID))!
        var jsonObject:[String:Any] =  [:]
        jsonObject["geolocations"] = toSerializedObject(locations: locations,jobID : jobID)
        print(jsonObject)
        let json = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        
        #if DEBUG
        print("\n------------------------------")
        print("Send Geolocations URL: \(url)")
        print("JSON: \(String(data:json, encoding:.utf8)!)")
        print("------------------------------\n")
        #endif
        let body =  json
        
        var request = basicRequest(url: url, method: Method.post.rawValue, body: body, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        request.setValue("text/json", forHTTPHeaderField: "Content-Type")
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            if apiResult.statusCode != nil && apiResult.statusCode == 200 {
                completion(true)
            }else {
                let data = try! PropertyListEncoder().encode(locations)
                self.saveLocation(jsonData: data)
                completion(false)
            }
        }
    }
    //MARK GET Driver status details
    static func getDriverStatusDetails(status:String,completion:@escaping (ApiResult)->()) {
        
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        var objStringURL = ApiConstants.DriverStatusDetails.getEndPoint()
        if status.count > 0{
            objStringURL += "/update/\(status)"
        }
        let url = URL(string: objStringURL)!
        let request = basicRequest(url: url, method: Method.get.rawValue, body: nil, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        #if DEBUG
        print("\n------------------------------")
        print("All Driver Status URL: \(url)")
        print("------------------------------\n")
        #endif
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            completion(apiResult)
        }
        
    }
    //MARK: GET JOB Call details
    static func getDriverCallDetails(jobID:Int,completion:@escaping (ApiResult)->()) {
        
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        let url = URL(string: ApiConstants.JobCallDetails.getEndPoint(id: jobID))!
        let request = basicRequest(url: url, method: Method.get.rawValue, body: nil, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        #if DEBUG
        print("\n------------------------------")
        print("All Driver Call URL: \(url)")
        print("------------------------------\n")
        #endif
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            completion(apiResult)
        }
        
    }
    //MARK: Driver Wages
    
    static func getUnnapprovedWages(completion:@escaping (ApiResult)->()) {
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        let url = URL(string: ApiConstants.Wages.getUnnapprovedWages())!
        let request = basicRequest(url: url, method: Method.get.rawValue, body: nil, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        #if DEBUG
        print("\n------------------------------")
        print("All Unapproved Wages URL: \(url)")
        print("------------------------------\n")
        #endif
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            completion(apiResult)
        }
        
    }
    
    static func actionOnWage(driverID : Int, wageID : Int, approve : Bool, reason:String) {
        
        let url = URL(string: ApiConstants.Wages.actionOnWage(wageId: wageID))!
        
        let jsonObject : [String:Any] = [
            "driver_approved":approve,
            "reason":reason
        ]
        
        let json = try! JSONSerialization.data(withJSONObject:jsonObject, options: .prettyPrinted)
        
        
        var request = basicRequest(url: url, method: Method.post.rawValue, body: json, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        #if DEBUG
        print("\n------------------------------")
        print("Set Wage as approved URL: \(url)")
        print("------------------------------\n")
        #endif
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            if apiResult.statusCode != nil && apiResult.statusCode == 200 {
                print("Wage approved: \(approve)\nReason: \(reason)")
            }
            else {
                UploadManager.shared.addFailedRequest(failedRequest: FailedRequest(driverID: AppManager.sharedInstance.currentUser!.driverID, jobID: nil, messageID: nil, wageID: wageID, approve: approve, reason: reason, request: RequestNames.wageApproval.rawValue, status: nil, locations: nil))
            }
        }
    }
    
    static func actionOnWageWithCompletion(driverID : Int, wageID : Int, approve : Bool, reason:String, completion:@escaping (Bool)->()) {
        
        let url = URL(string: ApiConstants.Wages.actionOnWage(wageId: wageID))!
        
        let jsonObject : [String:Any] = [
            "driver_approved":approve,
            "reason":reason
        ]
        
        let json = try! JSONSerialization.data(withJSONObject:jsonObject, options: .prettyPrinted)
        
        
        var request = basicRequest(url: url, method: Method.post.rawValue, body: json, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        #if DEBUG
        print("\n------------------------------")
        print("Set Wage as approved URL: \(url)")
        print("------------------------------\n")
        #endif
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            if apiResult.statusCode != nil && apiResult.statusCode == 200 {
                print("Wage approved: \(approve)\nReason: \(reason)")
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    
    //MARK: Message
    
    
    static func getMessages(driverID : Int, completion:@escaping (ApiResult)->()) {
        
        let url = URL(string: ApiConstants.Messages.getMessages(driverId: driverID))!
        let request = basicRequest(url: url, method: Method.get.rawValue, body: nil, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        #if DEBUG
        print("\n------------------------------")
        print("All Messages URL: \(url)")
        print("------------------------------\n")
        #endif
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            completion(apiResult)
        }
        
    }

    
    static func getUnreadMessages(driverID : Int, completion:@escaping (ApiResult)->()) {
        
        let url = URL(string: ApiConstants.Messages.getUnreadMessages(driverId: driverID))!
        let request = basicRequest(url: url, method: Method.get.rawValue, body: nil, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        #if DEBUG
        print("\n------------------------------")
        print("All Unread Messages URL: \(url)")
        print("------------------------------\n")
        #endif
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            completion(apiResult)
        }
        
    }
    
    static func markAsRead(driverID : Int, jobID : Int, messageID : Int) {
        
        let url = URL(string: ApiConstants.Messages.markAsRead(driverId: driverID))!
        
        let json = try! JSONSerialization.data(withJSONObject:["driver_message_ids":[messageID]], options: .prettyPrinted)
        
        
        var request = basicRequest(url: url, method: Method.post.rawValue, body: json, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        request.setValue("text/json", forHTTPHeaderField: "Content-Type")
        
        #if DEBUG
        print("\n------------------------------")
        print("Mark message as read URL: \(url)")
        print("------------------------------\n")
        #endif
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            if apiResult.statusCode != nil && apiResult.statusCode == 200 {
                print("Marked as read: \(messageID)")
            }
            else {
                
                
                UploadManager.shared.addFailedRequest(failedRequest: FailedRequest(driverID: AppManager.sharedInstance.currentUser!.driverID, jobID: jobID, messageID: messageID, wageID: nil, approve: nil, reason: nil, request: RequestNames.markAsRead.rawValue, status: nil, locations: nil))
            }
        }
    }
    
    static func markAsReadWithCompletion(driverID : Int, jobID : Int, messageID : Int, completion:@escaping (Bool)->()) {
        
        let url = URL(string: ApiConstants.Messages.markAsRead(driverId: driverID))!
        let json = try! JSONSerialization.data(withJSONObject:["driver_message_ids":[messageID]], options: .prettyPrinted)
        
        
        var request = basicRequest(url: url, method: Method.post.rawValue, body: json, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        request.setValue("text/json", forHTTPHeaderField: "Content-Type")
        
        #if DEBUG
        print("\n------------------------------")
        print("Mark message as read URL: \(url)")
        print("------------------------------\n")
        #endif
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            if apiResult.statusCode != nil && apiResult.statusCode == 200 {
                print("Marked as read: \(messageID)")
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    //MARK: Images
    
    static func uploadAppraisalImage(jobID : Int, path : String, filename : String, completion:@escaping (_ success:Bool)->()) {
        let url = URL(string:ApiConstants.AppriasalImages.getEndpoint(id: jobID, filename: filename))!
        /*imageUpload(endpoint: url, jobID: jobID, path: path, filename: filename, completion: {
            (success) in
            completion(success)
        })*/
        imageUploadCare(endpoint: url, jobID: jobID, path: path, filename: filename, completion: {
            (success) in
            completion(success)
        })
    }
    
    static func uploadExpensesImage(jobID : Int, path : String, filename : String, completion:@escaping (_ success:Bool)->()) {
        let url = URL(string:ApiConstants.ExpensesImages.getEndpoint(id: jobID, filename: filename))!
        /*imageUpload(endpoint: url, jobID: jobID, path: path, filename: filename, completion: {
            (success) in
            completion(success)
        })*/
        imageUploadCare(endpoint: url, jobID: jobID, path: path, filename: filename,isCustomerSignature: true, completion: {
            (success) in
            completion(success)
        })
    }
    
    static func uploadCustomerSignatureImage(jobID : Int, path : String, filename : String, completion:@escaping (_ success:Bool)->()) {
        
        let url = URL(string:ApiConstants.CustomerSignature.getEndpoint(id: jobID, filename: filename))!
        
        /*imageUpload(endpoint: url, jobID: jobID, path: path, filename: filename, completion: {
            (success) in
            completion(success)
        })*/
        imageUploadCare(endpoint: url, jobID: jobID, path: path, filename: filename,isCustomerSignature: true, completion: {
            (success) in
            completion(success)
        })
    }
    
    static func uploadFleetImage(jobID : Int, path : String, filename : String, completion:@escaping (_ success:Bool)->()) {
        let url = URL(string:ApiConstants.FleetPaperWork.getEndpoint(id: jobID, filename: filename))!
        /*imageUpload(endpoint: url, jobID: jobID, path: path, filename: filename, completion: {
            (success) in
            completion(success)
        })*/
        imageUploadCare(endpoint: url, jobID: jobID, path: path, filename: filename, completion: {
            (success) in
            completion(success)
        })
    }
    private static func imageUploadCare(endpoint : URL, jobID : Int, path : String, filename : String,isCustomerSignature:Bool = false, completion:@escaping (_ success:Bool)->())  {

        
        if let imagedataURL = URL.init(string: path){
        do{
            let data = try Data.init(contentsOf: imagedataURL,options: .mappedIfSafe)
         let uploadCareRequest = UCFileUploadRequest.init(fileData: data, fileName: "\(filename)", mimeType:"image/jpeg")
            UCClient.default()?.performUCRequest(uploadCareRequest, progress: { (totalBytesSent, totalBytesExpectedToSend) in
                print(totalBytesSent)
                print(totalBytesExpectedToSend)
            }, completion: { (response, error) in
                if let _ = error{
                    print("URL:- \(endpoint) \nError :-\n\(error!.localizedDescription)")
                    completion(false)
                }else{
                    print("URL:- \(endpoint) \nSuccess :-\n\(response ?? "")")
                    if let objResponse = response as? [String:Any],let udid = objResponse["file"]{
                        self.replaceJSONObject(jobid:jobID,fileName: filename,path:path, response: "\(udid)",isCustomerSignature:isCustomerSignature)
                    }
                    completion(true)
                }
            })
        }catch{
            let exception = NSException(name:NSExceptionName(rawValue: "imageUploadCare"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print("URL:- \(endpoint) \nError :-\n\(error.localizedDescription) \nPath:- \(path)")
            completion(false)
        }
        }else{
            completion(false)
        }
       
    }
    private static func replaceJSONObject(jobid:Int,fileName:String,path:String,response:String,isCustomerSignature:Bool = false){
        if let _ = AppManager.sharedInstance.currentUser{
            
        
        let path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobid) + "/job-appraisal" + "\(jobid)" + ".json"
        
        do {
            let data = try Data(contentsOf: URL(string:path)!)
            if let strJSON = String.init(data: data, encoding: .utf8){
                
                let uploadCareURL = "\(NSString.uc_path(withUUID: response) ?? "")\(fileName.replacingOccurrences(of:"-", with:""))"
                print(strJSON.countInstances(of: "\(fileName)"))
                let updateString = self.getUpdateStringReplacedWithUploadCareURL(fileName: "\(fileName)",path: path,uploadCareURL:uploadCareURL, oldJSONString: strJSON,isCustomerSignature:isCustomerSignature)
                print(updateString)
                if let updatedData = updateString.data(using: .utf8){
                    try updatedData.write(to: URL(string:path)!, options: .atomicWrite)
                    let appManager = AppManager.sharedInstance
                    if appManager.currentJob != nil {
                        appManager.currentJobAppraisal = fetchJobAppraisal(job: appManager.currentJob!)
//                        fetchExpenses(job: appManager.currentJobAppraisal!)
                        
                    }
                    
                }
                
            }
        }catch{
            let exception = NSException(name:NSExceptionName(rawValue: "replaceJSONObject"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }
        print(path)
        print(fileName)
        print(response)
        }
    }
    static func fetchExpenses(job:JobAppraisal) {
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        let path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: job.jobID!) + "/expenses-" + "\(job.jobID!)" + ".json"
        let filepath = path.replacingOccurrences(of: "file://", with: "")
        guard FileManager().fileExists(atPath: filepath) else{
            return 
        }
        do {
            let data = try Data(contentsOf: URL(string:path)!)
            
            let arrayOfExpenses = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:Any]]
            
            job.expenses = []
            
            for expenseObject in arrayOfExpenses {
                let expense = Expense(cost: nil, itemDescription: nil, photoReceiptName: nil, isJetWash: nil)
                expense.itemDescription = expenseObject[Model.ITEM_DESCRIPTION] as? String
                expense.photoReceiptName = expenseObject[Model.PHOTO_NAME] as? String
                expense.uploadCarephotoReceiptName = expenseObject[Model.UPLOADCARE_PHOTO_NAME] as? String
                expense.setCostFromPennies(pennies: expenseObject[Model.COST] as! Int)
                if expenseObject["is_jet_wash"] != nil {
                    expense.isJetWash = expenseObject["is_jet_wash"] as! Bool
                }
                
                job.expenses.append(expense)
            }
            print("fetched expenses")
        }
        catch {
            let exception = NSException(name:NSExceptionName(rawValue: "fetchExpenses"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print("no expenses")
        }
        
        
        
    }
    
    static func hasJobBeenStarted(job : Job)->Bool {
        guard let _ = AppManager.sharedInstance.currentUser else {
            return false
        }
        //check if json exist for job, which means it has been started
        var path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: job.id!) + "/job-appraisal" + "\(job.id!)" + ".json"
        
        
        path = path.replacingOccurrences(of: "file://", with: "")
        return FileManager().fileExists(atPath: path)
    }
    
    static func fetchJobAppraisal(job : Job)->JobAppraisal {
        
        if hasJobBeenStarted(job: job),let _ = AppManager.sharedInstance.currentUser {
            //load started json
            
            print("Job has been started")
            
            do {
                
                let path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: job.id!) + "/job-appraisal" + "\(job.id!)" + ".json"
                
                let data = try Data(contentsOf: URL(string:path)!)
                
                return try JSONDecoder().decode(JobAppraisal.self, from: data)
                
                
            }
            catch {
                let exception = NSException(name:NSExceptionName(rawValue: "fetchJobAppraisal"),
                                            reason:"\(error.localizedDescription)",
                    userInfo:nil)
                Bugsnag.notify(exception)
                print("Error Parsing JSON: \(error)")
                
            }
            
            
            
        }
        print("Job has NOT been started")
        return JobAppraisal(id: job.id!)
    }

    private static func getUpdateStringReplacedWithUploadCareURL(fileName:String,path:String,uploadCareURL:String,oldJSONString:String,isCustomerSignature:Bool = false)->String{
        let ranges = oldJSONString.ranges(of: "\"\(fileName)\"", options: .regularExpression)
        var updateString = ""
        if ranges.count == 1{
            return oldJSONString
        }else if ranges.count == 2{
            let tempFileName = fileName.replacingOccurrences(of:"-", with:"")
            if oldJSONString.ranges(of:"\(tempFileName)", options: .regularExpression).count == 2{
                if OfflineFolderStructure.doesFileExist(path: path){
                    let fm = FileManager.default
                    do {
                        try fm.removeItem(at: URL(string:path)!)
                    }catch let error {
                        let exception = NSException(name:NSExceptionName(rawValue: "getUpdateStringReplacedWithUploadCareURL"),
                                                    reason:"\(error.localizedDescription)",
                            userInfo:nil)
                        Bugsnag.notify(exception)
                        print("Error Deleting: \(error.localizedDescription)")
                    }
                }
                return oldJSONString
            }
            if let lastRange = isCustomerSignature ? ranges.first : ranges.last{
                updateString = oldJSONString.replacingCharacters(in: lastRange, with: "\"\(uploadCareURL)\"")
            }
        }else if (ranges.count % 2 == 0),ranges.count > 2{
             let secondObject = ranges[1]
             let updateStringOnSecondObject = oldJSONString.replacingCharacters(in: secondObject, with: "\"\(uploadCareURL)\"")
             let rangesAfterSecondUpdate = updateStringOnSecondObject.ranges(of: "\"\(fileName)\"", options: .regularExpression)
            if let lastRange = rangesAfterSecondUpdate.last{
                updateString = updateStringOnSecondObject.replacingCharacters(in: lastRange, with: "\"\(uploadCareURL)\"")
            }
            
        }else{
            if let lastRange = ranges.last{
                updateString = oldJSONString.replacingCharacters(in: lastRange, with: "\"\(uploadCareURL)\"")
            }
        }
        if updateString.count > 0{
            return updateString
        }else{
            return oldJSONString
        }
    }
    private static func imageUpload(endpoint : URL, jobID : Int, path : String, filename : String, completion:@escaping (_ success:Bool)->())  {
        
        if let image = UIImage(contentsOfFile: path.replacingOccurrences(of: "file://", with: "")){
        
            
        
        let boundary = "Boundary-\(NSUUID().uuidString)"
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(image.jpegData(compressionQuality: 0.75)!)//UIImageJPEGRepresentation(image, Defaults.compression)!)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        var request = basicRequest(url: endpoint, method: Method.post.rawValue, body: body, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        #if DEBUG
            print("\n------------------------------")
            print("Send Images URL: \(endpoint)")
            print("------------------------------\n")
        #endif
        
        
        
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            
            if apiResult.statusCode != nil && apiResult.statusCode == 200 {
                completion(true)
            }
            else {
                completion(false)
            }
         }
        }else{
            completion(false)
        }
    }
    
    //MARK:  Expenses
    
    public static func pushExpenses(jobID : Int, expenses:Data) {
        let url = URL(string:ApiConstants.Expenses.getEndpoint(id: jobID))!
        let body =  expenses
        
        #if DEBUG
            print("\n------------------------------")
            print("Push Expenses URL: \(url)")
            print("Body: \(body)")
            print("------------------------------\n")
        #endif
        
        var request = basicRequest(url: url, method: Method.post.rawValue, body: body, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        request.setValue("text/json", forHTTPHeaderField: "Content-Type")
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            if apiResult.statusCode != nil && apiResult.statusCode == 200 {
                
            }
            else {
                //failed
                UploadManager.shared.addFailedRequest(failedRequest: FailedRequest(driverID: AppManager.sharedInstance.currentUser!.driverID, jobID: jobID, messageID: nil, wageID: nil, approve: nil, reason: nil, request: RequestNames.expenses.rawValue, status: nil, locations: nil))
            }
        }
        
        
    }
    
    public static func pushExpensesWithCompletion(jobID : Int, expenses:Data, completion:@escaping (Bool)->()) {
        let url = URL(string:ApiConstants.Expenses.getEndpoint(id: jobID))!
        let body =  expenses
        
        #if DEBUG
        print("\n------------------------------")
        print("Push Expenses URL: \(url)")
        print("Body: \(body)")
        print("------------------------------\n")
        #endif
        
        var request = basicRequest(url: url, method: Method.post.rawValue, body: body, accessToken: AppManager.sharedInstance.currentUser!.accessToken!)
        request.setValue("text/json", forHTTPHeaderField: "Content-Type")
        
        Response.shared.basicNew(urlRequest: request) { (apiResult) in
            if apiResult.statusCode != nil && apiResult.statusCode == 200 {
                completion(true)
            }
            else {
                //failed
               completion(false)
            }
        }
        
        
    }
    
    
    //MARK: GENERAL
    static func basicRequest(url:URL,method:String,body:Any?,accessToken:String?)->URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        if let bodyData = body as? Data {
            urlRequest.httpBody = bodyData
        }
        if let bodyString = body as? String {
            urlRequest.httpBody = bodyString.data(using: .utf8)
        }
        if accessToken != nil {
            print("\(accessToken)")
            urlRequest.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
        
    }
    
    
    
    
    
}
extension String {
    func countInstances(of stringToFind: String) -> Int {
        var stringToSearch = self
        var count = 0
        while let foundRange = stringToSearch.range(of: stringToFind, options: .diacriticInsensitive) {
            stringToSearch = stringToSearch.replacingCharacters(in: foundRange, with: "")
            count += 1
        }
        return count
    }
}
extension StringProtocol where Index == String.Index {
    func ranges<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        var start: Index = startIndex
        
        while let range = range(of: string, options: options, range: start..<endIndex) {
            ranges.append(range)
            start = range.upperBound
        }
        
        return ranges
    }
}
