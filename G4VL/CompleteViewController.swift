//
//  CompleteViewController.swift
//  G4VL
//
//  Created by Michael Miller on 02/05/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit
import Bugsnag

class CompleteViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        let path = OfflineFolderStructure.getJobPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: AppManager.sharedInstance.currentJobAppraisal!.jobID!)
        
        let file = "delete.txt"
        
        let text = "This text file is here to indicate that the job is finished and once all assets are uploaded the job folder can be removed from the device." //just a text
        
        //writing
        do {
            try text.write(to: URL(string: path+"/\(file)")!, atomically: true, encoding: .utf8)
        }
        catch {
            let exception = NSException(name:NSExceptionName(rawValue: "CompleteViewController"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            /* error handling here */
            print(error.localizedDescription)
        }
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func returnToDashBoard() {
        self.navigationController?.popToViewController(AppManager.sharedInstance.homeVC!, animated: true)
    }

}
