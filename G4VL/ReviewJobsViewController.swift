//
//  ReviewJobsViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 25/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import SwipeCellKit
import PopOverMenu

class ReviewJobsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate, UIPopoverPresentationControllerDelegate {
    
    var appManager = AppManager.sharedInstance
    @IBOutlet var seg : UISegmentedControl!
    @IBOutlet var theTable : UITableView!
    var content : [[Job]] = [[],[]]
    let dateFormatter = DateFormatter()
    @IBOutlet var swipeToLeftHeight:NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        content = [appManager.activeJobs,appManager.inactiveJobs]
        self.theTable.estimatedRowHeight = 200.0
        self.theTable.rowHeight = UITableView.automaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func didChangeJobType() {
        self.swipeToLeftHeight.constant = seg.selectedSegmentIndex == 1  ? 30 : 0.0
        theTable.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content[seg.selectedSegmentIndex].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! JobCell
        
        cell.delegate = self
        
        let job = content[seg.selectedSegmentIndex][indexPath.row]
        
        cell.lblJOBID.text = "JOB \(job.id ?? 0)"
        cell.statusLabel.text = "STATUS: \n\(job.status!.rawValue.replacingOccurrences(of: "_", with:" ").uppercased())"
        cell.carTypeLabel.text = job.getPickupDate()
        
        cell.dateLabel.text = getVehicleDescription(vehicle: job.vehicle!)
        cell.lblJOBID.text = "\nJOB \(job.id ?? 0) \n\nPICKUP: \n\(self.parseAddress(address: job.pickupAddress!)) \n\nCONTACT: \nName: \(job.pickupAddress!.contactName ?? "null")\nNumber: \(job.pickupAddress!.contactNumber ?? "null") \n\nDate: \n\(job.getPickupDate()) \n\nSchedule PickUp: \n\(job.getSchedulePickupDateAndTime())\n\nSTATUS: \n\(job.status!.rawValue.replacingOccurrences(of: "_", with:" ").uppercased())\n\nNUMBER PLATE: \n\(job.vehicle?.registrationNumber ?? "")\n"
        cell.dropOffDetail.text = "\n\nDROPOFF:\n\(self.parseAddress(address: job.dropoffAddress!)) \n\nCONTACT: \nName: \(job.dropoffAddress!.contactName ?? "null")\nNumber: \(job.dropoffAddress!.contactNumber ?? "null") \n\nDate: \n\(job.getDropOffDate()) \n\nSchedule DropOff: \n\(job.getScheduleDropOffDateAndTime())\n\nVEHICLE: \n\(self.getVehicleDescription(vehicle: job.vehicle!))\n\n Key To Key: \n\(job.keytokey ?? "")\n"
//        print(job.pickupAddress?.addressLine1)
//        print(job.dropoffAddress?.addressLine1)
        
        /*
        cell.destinationLabel.text = "\(job.pickupAddress!.townCity ?? job.pickupAddress!.postcode ?? "unknown") to \(job.dropoffAddress!.townCity ?? job.dropoffAddress!.postcode ?? "unknown")"
        */
        if appManager.currentJob != nil && job.id! == appManager.currentJobAppraisal!.jobID {
            
//            cell.layer.borderColor = UIColor(red: 122/255.0, green: 202/255.0, blue: 13/255.0, alpha: 1.0).cgColor
//            cell.layer.borderWidth = 3.0
            cell.backgroundColor = UIColor(red: 122/255.0, green: 202/255.0, blue: 13/255.0, alpha: 1.0)
        }else{
            cell.backgroundColor = UIColor.white
            //cell.layer.borderWidth = 0.0
        }
        
        return cell
    }
    func parseAddress(address:Address) -> String {
        
        var string = ""
        
        if address.houseNumberOrName != nil {
            string += address.houseNumberOrName! + " "
        }
        if address.addressLine1 != nil {
            string += address.addressLine1!
        }
        if address.addressLine2 != nil && address.addressLine2!.count > 0 {
            string += ", " + address.addressLine2!
        }
        if address.townCity != nil && address.townCity!.count > 0 {
            string += ", " + address.townCity!
        }
        if address.countyArea != nil && address.countyArea!.count > 0 {
            string += ", " + address.countyArea!
        }
        
        string += ", " + (address.postcode ?? "")
        
        return string
        
    }
    func getVehicleDescription(vehicle:Vehicle) -> String {
        var string = ""
        if vehicle.colour != nil {
            string += vehicle.colour! + " "
        }
        if vehicle.make != nil {
            string += vehicle.make! + " "
        }
        if vehicle.model != nil {
            string += vehicle.model! + ""
        }
        return string
    }
    
    func showConfirmationAlert(jobNumber:Int){
        if let keyWindow = UIApplication.shared.keyWindow,let rootViewController = keyWindow.rootViewController{
            let actionSheet = UIAlertController.init(title:"Confirmation", message:"I have checked the car and any damage matches the appraisal.", preferredStyle: .alert)
            
            let declineAction = UIAlertAction.init(title: "Decline", style: .default, handler: { (_ ) in
                Requests.changeJobStatusWithSplit(jobID: jobNumber, status: .accepted, isaccept: false)
                self.performSegue(withIdentifier: "to_job", sender: nil)
                
                rootViewController.dismiss(animated: true, completion: nil)
            })
            actionSheet.addAction(declineAction)
            
            let acceptAction = UIAlertAction.init(title: "Accept", style: .default, handler: { (_ ) in
                Requests.changeJobStatusWithSplit(jobID: jobNumber, status: .accepted, isaccept: true)
                self.performSegue(withIdentifier: "to_job", sender: nil)

                rootViewController.dismiss(animated: true, completion: nil)
            })
            actionSheet.addAction(acceptAction)
            
            rootViewController.present(actionSheet, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
       
        if seg.selectedSegmentIndex == 1 {
            
            if orientation == .right {
                
                let acceptAction = SwipeAction(style: .default, title: nil, handler: { action, indexPath in
                    //handle action by updating model with deletion
                    let job = self.content[1][indexPath.row]
                    if let strSplitSequence = job.splitSequence,strSplitSequence == "2"{
                        self.showConfirmationAlert(jobNumber: job.id!)
                    }
                    //remove job from inactive list
                    let index = self.appManager.inactiveJobs.index(of: job)
                    self.appManager.inactiveJobs.remove(at: index!)
                    self.appManager.activeJobs.append(job)
                    
                    //set job as active, locally and remotely
                    let jobAppraisal = JobAppraisal(id: job.id!)
                    
                    jobAppraisal.status = .accepted//locally
                    Requests.changeJobStatus(jobID: job.id!, status: .accepted)//remotely
                    
                   //save job locally
                    JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
                    
                    //update current content
                    
                    self.appManager.currentJob = job
                    self.appManager.currentJobAppraisal = jobAppraisal
                    self.content[1].remove(at: indexPath.row)
                    self.content[0].append(job)
                    self.performSegue(withIdentifier: "to_job", sender: nil)
                    
                })

                acceptAction.textColor = .white
                acceptAction.image = UIImage(named: "check")?.maskWithColor(color: .white)
                acceptAction.backgroundColor = UIColor(red: 122/255.0, green: 202/255.0, blue: 13/255.0, alpha: 1.0)
                
                acceptAction.transitionDelegate = ScaleTransition.default
                
                return [acceptAction]
            }
            else {
                
                let callAction = SwipeAction(style: .default, title: nil, handler: { action, indexPath in
                   
//                    UIApplication.shared.open(URL(string:"tel:\(self.appManager.currentUser!.officeNumber!)")!, options: [:], completionHandler: {
//                        finished in
//                    })
                   
                    self.tapped()
                    
                })
                callAction.textColor = .white
                callAction.image = UIImage(named: "call")?.maskWithColor(color: .white)
                callAction.backgroundColor = UIColor(red: 135/255.0, green: 135/255.0, blue: 184/255.0, alpha: 1.0)
                callAction.transitionDelegate = ScaleTransition.default
                
                return [callAction]
            }
            
        }
        
        return nil
    }
    func tapped() {
        
        let job = AppManager.sharedInstance.currentJob
        //            let number = job.customer!.contactTelephone1 ?? job.customer!.contactTelephone2,
        //            let url = URL(string: "tel://\(number)") {
        //            print(job.pickupAddress?.contactNumber)
        //            print(job.dropoffAddress?.contactNumber)
        
        if let keyWindow = UIApplication.shared.keyWindow,let rootViewController = keyWindow.rootViewController{
            let actionSheet = UIAlertController.init(title:nil, message:nil, preferredStyle: .actionSheet)
            
            let pickUpAction = UIAlertAction.init(title: "Pickup : \(job?.pickupAddress?.contactNumber ?? "")", style: .default) { (_ ) in
                if let pickUpNumber = job?.pickupAddress?.contactNumber?.replacingOccurrences(of:" ", with: "") ,
                    let pickUpURL = URL(string: "tel://\(pickUpNumber)"),pickUpNumber.count > 0{
                    UIApplication.shared.open(pickUpURL, options: [:]) { (finished) in
                    }
                }
            }
            actionSheet.addAction(pickUpAction)
            let dropAction = UIAlertAction.init(title: "Dropoff : \(job?.dropoffAddress?.contactNumber ?? "")", style: .default) { (_ ) in
                if let pickUpNumber = job?.dropoffAddress?.contactNumber?.replacingOccurrences(of:" ", with: "") ,
                    let pickUpURL = URL(string: "tel://\(pickUpNumber)"),pickUpNumber.count > 0{
                    UIApplication.shared.open(pickUpURL, options: [:]) { (finished) in
                    }
                }
            }
            actionSheet.addAction(dropAction)
            var strOfficeMobileNumber = ""
            if let officeNumber = AppManager.sharedInstance.currentUser?.officeNumber{
                strOfficeMobileNumber = officeNumber
            }
            let officeAction = UIAlertAction.init(title: "Office : \(strOfficeMobileNumber)", style: .default) { (_ ) in
                let pickUpNumber = strOfficeMobileNumber.replacingOccurrences(of:" ", with: "")
                if let pickUpURL = URL(string: "tel://\(pickUpNumber)"),pickUpNumber.count > 0{
                    
                    UIApplication.shared.open(pickUpURL, options: [:]) { (finished) in
                        
                    }
                }
            }
            actionSheet.addAction(officeAction)
            let cancelAction = UIAlertAction.init(title:"Cancel", style: .cancel) { (_ ) in
                
            }
            actionSheet.addAction(cancelAction)
            rootViewController.present(actionSheet, animated: true, completion: nil)
        }
        /*
         UIApplication.shared.open(url, options: [:]) { (finished) in
         
         }*/
        //        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if seg.selectedSegmentIndex != 0 {
            return
        }
        let job = self.content[0][indexPath.row]
        
        if appManager.currentJob != nil {
            if job.id! == appManager.currentJobAppraisal!.jobID {
                self.view.makeToast("This is the current Job", point: self.view.center, title: nil, image: nil, completion: nil)
                return
            }
        }
        
        
        let alert = UIAlertController(title: "", message: "Do you want to set this to the current job?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            
            self.appManager.currentJob = job
            self.appManager.currentJobAppraisal = JobsManager.fetchJobAppraisal(job: job)
            JobsManager.saveJobAppraisal(job: self.appManager.currentJobAppraisal!, saveExpenses: false)
            
            
            tableView.reloadData()
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        
        if orientation == .right {
            var options = SwipeTableOptions()
            options.expansionStyle = .destructive
            options.transitionStyle = .border
            return options
        }
        else {
            var options = SwipeTableOptions()
            options.expansionStyle = .selection
            options.transitionStyle = .border
            return options
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        
    }
    //MARK: Filter View
    
    @IBAction func showFilter(sender:UIView) {
        let titles = [
            "Pickup Date (ASC)",
            "Pickup Date (DESC)",
            "Pickup Location (A-Z)",
            "Pickup Location (Z-A)",
            "Dropoff Location (A-Z)",
            "Dropoff Location (Z-A)"
        ]
        
        let popOverViewController = PopOverViewController.instantiate()
        popOverViewController.set(titles: titles) //setTitles(titles)
        
        popOverViewController.set(separatorStyle: .singleLine)//setSeparatorStyle(.singleLine)
        
        popOverViewController.popoverPresentationController?.sourceView = sender.superview!
        popOverViewController.popoverPresentationController?.sourceRect = CGRect(x: sender.frame.origin.x + sender.frame.size.width - 16, y: sender.frame.origin.y + sender.frame.size.height/2, width: 16, height: 16)
        popOverViewController.preferredContentSize = CGSize(width: 200, height:275)
        popOverViewController.presentationController?.delegate = self
        popOverViewController.completionHandler = { selectRow in
            
            switch (selectRow) {
            case 0://date ascending
                
                if self.seg.selectedSegmentIndex == 0
                {
                    self.appManager.activeJobs = self.appManager.activeJobs.sorted {
                        
                        let date1 = self.dateFormatter.date(from: $1.getPickupDate())!
                        let date2 = self.dateFormatter.date(from: $0.getPickupDate())!
                        
                        return date1 > date2
                    }
                    
                }
                else {
                    self.appManager.inactiveJobs = self.appManager.inactiveJobs.sorted {
                        
                        let date1 = self.dateFormatter.date(from: $1.getPickupDate())!
                        let date2 = self.dateFormatter.date(from: $0.getPickupDate())!
                        
                        return date1 > date2
                    }
                }
                
                break
            case 1://date descending
                if self.seg.selectedSegmentIndex == 0
                {
                    self.appManager.activeJobs = self.appManager.activeJobs.sorted {
                        
                        let date1 = self.dateFormatter.date(from: $1.getPickupDate())!
                        let date2 = self.dateFormatter.date(from: $0.getPickupDate())!
                        
                         return date1 < date2
                    }
                    
                }
                else {
                    self.appManager.inactiveJobs = self.appManager.inactiveJobs.sorted {
                        
                        let date1 = self.dateFormatter.date(from: $1.getPickupDate())!
                        let date2 = self.dateFormatter.date(from: $0.getPickupDate())!
                        
                        return date1 < date2
                    }
                }
                
                break
            case 2://pickup a to z
                
                if self.seg.selectedSegmentIndex == 0
                {
                    self.appManager.activeJobs = self.appManager.activeJobs.sorted {
                        return $1.pickupAddress!.townCity! < $0.pickupAddress!.townCity!
                    }
                }
                else {
                    self.appManager.inactiveJobs = self.appManager.inactiveJobs.sorted {
                        return $1.pickupAddress!.townCity! < $0.pickupAddress!.townCity!
                    }
                }
                
                break
            case 3://pickup a to
                
                if self.seg.selectedSegmentIndex == 0
                {
                    self.appManager.activeJobs = self.appManager.activeJobs.sorted {
                        return $1.pickupAddress!.townCity! > $0.pickupAddress!.townCity!
                    }
                }
                else {
                    self.appManager.inactiveJobs = self.appManager.inactiveJobs.sorted {
                        return $1.pickupAddress!.townCity! > $0.pickupAddress!.townCity!
                    }
                }
                
                break
            case 4://dropoff a to z
                
                if self.seg.selectedSegmentIndex == 0
                {
                    self.appManager.activeJobs = self.appManager.activeJobs.sorted {
                        return $1.dropoffAddress!.townCity! > $0.dropoffAddress!.townCity!
                    }
                }
                else {
                    self.appManager.inactiveJobs = self.appManager.inactiveJobs.sorted {
                        return $1.dropoffAddress!.townCity! > $0.dropoffAddress!.townCity!
                    }
                }
                
                break
            default://dropoff z to a
                
                if self.seg.selectedSegmentIndex == 0
                {
                    self.appManager.activeJobs = self.appManager.activeJobs.sorted {
                        return $1.dropoffAddress!.townCity! < $0.dropoffAddress!.townCity!
                    }
                }
                else {
                    self.appManager.inactiveJobs = self.appManager.inactiveJobs.sorted {
                        return $1.dropoffAddress!.townCity! < $0.dropoffAddress!.townCity!
                    }
                }
                
                
                break
            }
            self.content = [self.appManager.activeJobs, self.appManager.inactiveJobs]
            self.theTable.reloadData()
        };
        present(popOverViewController, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}
