//
//  SpecialInstructionsViewController.swift
//  G4VL
//
//  Created by Michael Miller on 04/06/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

class SpecialInstructionsViewController: UIViewController {
    
    @IBOutlet var specialInstructionsLabel : UILabel!
    
    @IBOutlet var specialInstructionsTextView: UITextView!

    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        specialInstructionsLabel.text = AppManager.sharedInstance.currentJob!.specialInstructions ?? ""
        specialInstructionsTextView.text = AppManager.sharedInstance.currentJob!.specialInstructions ?? ""

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func yes() {
        AppManager.sharedInstance.currentJobAppraisal!.specialInstructionsComplete = true
        JobsManager.saveJobAppraisal(job: AppManager.sharedInstance.currentJobAppraisal!, saveExpenses: false)
        self.back()
    }

}
