//
//  JobsManager.swift
//  G4VL
//
//  Created by Foamy iMac7 on 18/10/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import Bugsnag

class JobsManager: NSObject {

    //MARK: Jobs
    
    
    static func sortJobs() {
        
        let appManager = AppManager.sharedInstance
        
        appManager.currentJob = nil
        appManager.inactiveJobs = []
        appManager.activeJobs = []
        
        appManager.activeJobs = appManager.allJobs.filter {
                $0.status != .inactive &&
                $0.status != .completed &&
                $0.status != .completedAwaitingData &&
                $0.status != .declined
        }
        print(appManager.activeJobs.count)
        
        appManager.inactiveJobs = AppManager.sharedInstance.allJobs.filter { $0.status == .inactive }
        
        print(appManager.inactiveJobs.count)
        
        if appManager.activeJobs.count == 1 {
            //only 1 active job
            print("Only 1 active Job")
            appManager.currentJob = appManager.activeJobs.first!
           
        }
        else {
            //more than 1 active job
            appManager.currentJob = getMostRecentlyEditedJob()
        }
        
        if appManager.currentJob != nil {
            appManager.currentJobAppraisal = fetchJobAppraisal(job: appManager.currentJob!)
            fetchExpenses(job: appManager.currentJobAppraisal!)
        }
        
         NotificationCenter.default.post(name: NSNotification.Name(Notification.REFRESH_JOBS), object: nil)
    }
    
    private static func getMostRecentlyEditedJob() -> Job? {
        guard let _ = AppManager.sharedInstance.currentUser else {
            return nil
        }
        if AppManager.sharedInstance.activeJobs.count == 0 {
            return nil
        }
        let id = UserDefaults.standard.integer(forKey: Preferences.LAST_OPENED)
        
        if id != 0  {
            for job in AppManager.sharedInstance.activeJobs {
                if job.id == id && job.driverId == AppManager.sharedInstance.currentUser!.driverID {
                    return job
                }
            }
        }
        return nil
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
            catch{
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
    
    static func saveJobAppraisal(job:JobAppraisal, saveExpenses:Bool) {
        
        
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        //////////Create the folder paths, if not already created
        OfflineFolderStructure.createRequiredFolders(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: job.jobID!)
        ///////////
        
        do {
            let jsonData = try JSONEncoder().encode(job)
            
            let path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: job.jobID!) + "/job-appraisal" + "\(job.jobID!)" + ".json"
            
            try jsonData.write(to: URL(string:path)!, options: .atomicWrite)
            print("JSON SAVED: Job \(job.jobID!)")
            
        } catch  {
            let exception = NSException(name:NSExceptionName(rawValue: "saveJobAppraisal"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print ("JSON Save Failure: \(error.localizedDescription)");
        }
        if job.expenses.count > 0 && saveExpenses {
            self.saveExpenses(job: job)
        }
    }
    
    private static func saveExpenses(job:JobAppraisal) {
        var arrayOfExpenseObjects : [[String:Any]] = []
        for expense in job.expenses {
            let expenseObj : [String:Any] = [
                Model.COST : expense.getCostInPennies(),
                Model.ITEM_DESCRIPTION : expense.itemDescription ?? "",
                Model.PHOTO_NAME:expense.photoReceiptName ?? "",
                Model.UPLOADCARE_PHOTO_NAME:expense.uploadCarephotoReceiptName ?? ""
            
            ]
            arrayOfExpenseObjects.append(expenseObj)
        }
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        let path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: job.jobID!) + "/expenses-" + "\(job.jobID!)" + ".json"
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: arrayOfExpenseObjects, options: JSONSerialization.WritingOptions.prettyPrinted) as Data
            
            try jsonData.write(to: URL(string:path)!, options: .atomicWrite)
            
            print("EXPENSES SAVED: Job \(job.jobID!)")
            
            Requests.pushExpenses(jobID: job.jobID!, expenses:jsonData )
            
        } catch  {
            let exception = NSException(name:NSExceptionName(rawValue: "saveExpenses"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print ("EXPENSES Save Failure: \(error.localizedDescription)");
        }
        
        
    }
    
    
    
    static func doesFileExist(jobID : Int, completion:(Bool)->()) {
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        let dataPath = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobID)
        
        let url = URL(fileURLWithPath: dataPath)
        
        let filePath = url.appendingPathComponent("job-" + "\(jobID)" + ".json").path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            completion(true)
        } else {
            completion(false)
        }
        
        
    }
    
    static func downloadJobAndOverwrite(completion:(_ success:Bool)->()) {
    
        
    
    }
    
    static func updateJobWith(id:Int, completion:(_ success : Bool)->()) {
        //occurs when an admin makes minor edits to a job
        
        doesFileExist(jobID: id) { (exists) in
            if exists {
                
                
                self.downloadJobAndOverwrite(completion: { (success) in
                    completion(success)
                })
                
                
            }
            else {
                completion(true)
            }
        }
        
        
    }
    
    static func generatePODSFile(job:JobAppraisal, completion:(_ url:URL?,_ error : Error?)->())  {
        
        
        do {
            let podAppraisal = POD(jobAppraisal: job)
            
            let jsonData = try JSONEncoder().encode(podAppraisal)
            guard let _ = AppManager.sharedInstance.currentUser else {
                return
            }
            let path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: job.jobID!) + "/pod-" + "\(job.jobID!)" + ".json"
            
            let url = URL(string:path)!
            
            try jsonData.write(to: url, options: Data.WritingOptions.atomic)
            
            completion(url, nil)
          
        }
        catch let error {
            let exception = NSException(name:NSExceptionName(rawValue: "generatePODSFile"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print("generatePODSFile \(error.localizedDescription)")
            completion(nil, error)
        }
        
        
        
      
        
    }
    
  
}
