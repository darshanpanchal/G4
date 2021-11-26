//
//  ExtrasViewController.swift
//  G4VL
//
//  Created by Michael Miller on 05/07/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit

class ExtrasViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    

    var appManager = AppManager.sharedInstance
    var waitingTimePicker = UIPickerView()
    
    var hours : [String] = []
    var minutes : [String] = []
    
    var jobAppraisal : JobAppraisal {
        return AppManager.sharedInstance.currentJobAppraisal!
    }
    
    var pickup = true
    var entry : ExtraEntry?
    
    @IBOutlet var txtWaitingTime : UITextField!
    
    @IBOutlet var btnConfirm : UIButton!
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if appManager.currentJobAppraisal!.extras == nil {
            appManager.currentJobAppraisal!.extras = Extras(pickup: nil, dropoff: nil)
        }
        
        if pickup {
            entry = appManager.currentJobAppraisal!.extras!.pickup
        }
        else {
            entry = appManager.currentJobAppraisal!.extras!.dropoff
        }
        
        for i in 0..<16 {
            hours.append("\(i) hours")
        }
        
        for i in 0..<15 {
            minutes.append("\(i*5) minutes")
        }
        
        txtWaitingTime.inputView = waitingTimePicker
        waitingTimePicker.delegate = self;
        waitingTimePicker.dataSource = self
        
        if entry!.waitingTime.value != 0 {
            txtWaitingTime.text = ""
        }
        else {
            let hours = entry!.waitingTime.value / 60 / 60
            let minutes = entry!.waitingTime.value / 60 % 60
            waitingTimePicker.selectRow(hours, inComponent: 0, animated: false)
            waitingTimePicker.selectRow(minutes/5, inComponent: 1, animated: false)
            
            
            txtWaitingTime.text = "\(hours) hours \(minutes) minutes"
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirm() {
        
        if (waitingTimePicker.selectedRow(inComponent: 0) == 0 && waitingTimePicker.selectedRow(inComponent: 1) == 0) || txtWaitingTime.text!.count == 0 {
            entry!.waitingTime.value = 0
        }
        else {
            let h = Int(self.hours[waitingTimePicker.selectedRow(inComponent: 0)].replacingOccurrences(of: " hours", with: ""))!
            let m = Int(self.minutes[waitingTimePicker.selectedRow(inComponent: 1)].replacingOccurrences(of: " minutes", with: ""))! * 5
            
            let inSeconds = (h * 60 * 60) + (m * 60)
            entry!.waitingTime.value = inSeconds
            
        }
        
        entry!.complete = true
        
        JobsManager.saveJobAppraisal(job: appManager.currentJobAppraisal!, saveExpenses: false)
        
        back()
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hours.count
        case 1:
            return minutes.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return hours[row]
        case 1:
            return minutes[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtWaitingTime.text = "\(hours[pickerView.selectedRow(inComponent: 0)]) \(minutes[pickerView.selectedRow(inComponent: 1)])"
    }

}
