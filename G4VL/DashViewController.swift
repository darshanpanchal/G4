//
//  DashViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 25/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import LocalAuthentication
import PushNotifications
import Bugsnag


extension Bundle {
    
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
    
}

class DashViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var loaded = false
    var appManager = AppManager.sharedInstance
    @IBOutlet var noActiveJobView : UIView!
    var pushNotifications = PushNotifications.shared
    @IBOutlet var goToAppraisalControl : UIControl!
    @IBOutlet var jobStatusLabel : UILabel!
    @IBOutlet var versionLabel : UILabel!
    var labelT : CGAffineTransform?
    var pulseAnimation:CABasicAnimation?
    
    @IBOutlet var completeJobView:UIView!
    
    @IBOutlet var lblNumberOfJobsToReview : UILabel!
    
    @IBOutlet var theTable : UITableView!
    
    @IBOutlet var driverStatusSegement:UISegmentedControl!
    
    @IBOutlet var buttonViewExpense:UIButton!
    @IBOutlet var buttonWages:UIButton!
    
    
    var content : [[(String,String)]] = []
    var sectionTitles : [String] = ["Job Specifics","Job Documents","Pickup","Dropoff","Vehicle","Company"]
    
    let dateFormatter = DateFormatter()
    
    @IBAction func logout() {
        URLSession.shared.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
        NotificationCenter.default.post(name: NSNotification.Name(Notification.LOG_OUT), object: nil)
        appManager.defaults.set(false, forKey: Preferences.TOUCH_ID_ENABLED)
        appManager.defaults.set(false, forKey: Preferences.TOUCH_ID_REQUESTED)
        appManager.defaults.synchronize()
        User.removeUserFromUserDefault()
        appManager.currentUser = nil
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    @IBAction func driperSupportCall(sender:UIButton){
        let pickUpNumber = "+4401782939079"
        if let pickUpURL = URL(string: "tel://\(pickUpNumber)"),pickUpNumber.count > 0{
            UIApplication.shared.open(pickUpURL, options: [:]) { (finished) in
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        appManager.homeVC = self
        
        dateFormatter.dateFormat = "EEE dd/MM/yyyy"
        
        versionLabel.text = "Current version \(Bundle.main.versionNumber) (\(Bundle.main.buildNumber))"
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(Notification.REFRESH_JOBS), object: nil)
        
        buttonWages.clipsToBounds = true
        buttonWages.layer.borderColor = UIColor(red: 58/255.0, green: 58/255.0, blue: 86/255.0, alpha: 1.0).cgColor
        buttonWages.layer.borderWidth = 0.7
        buttonViewExpense.clipsToBounds = true
        buttonViewExpense.layer.borderColor = UIColor(red: 58/255.0, green: 58/255.0, blue: 86/255.0, alpha: 1.0).cgColor
        buttonViewExpense.layer.borderWidth = 0.7
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
    }
    
    
    
    func subscribeToPushNotifications() {
        do {
            try self.pushNotifications.subscribe(interest: AppManager.sharedInstance.currentUser!.pushNotificationInterest)
        }
        catch let error {
            let exception = NSException(name:NSExceptionName(rawValue: "subscribeToPushNotifications"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
            print("Subscribe to notification error: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.loadJobs()
        self.getDriverStatus()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UploadManager.shared.checkForWaitingUploads()
        
        subscribeToPushNotifications()
        
        
        //biometrics
        if !appManager.defaults.bool(forKey: Preferences.TOUCH_ID_REQUESTED) {
            
            var error: NSError?
            
            let context = LAContext()
            
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                
                let idType = Biometrics.checkForBiometry(context: context)
                if idType == .kNone {
                    return
                }
                
                let title = idType == .kFace ? "FaceID" : "Touch ID"
                let message = idType == .kFace ? "Do you wish to enable FaceID for a speedy login?" : "Do you wish to enable TouchID for a speedy login?"
                let reasonString = idType == .kFace ? "Confirm with face recognition" : "Confirm with fingerprint"
                
                let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Enable", style: .default, handler: {
                    action in
                    
                    
                    
                    
                    // Set the reason string that will appear on the authentication alert.
                    
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: {
                        success, error in
                        if success {
                            
                            self.appManager.defaults.set(true, forKey: Preferences.TOUCH_ID_ENABLED)
                            self.appManager.defaults.set(true, forKey: Preferences.TOUCH_ID_REQUESTED)
                            UserDefaults.standard.synchronize()
                        }
                        
                        if error != nil {
                            print("Touch/FaceID error: \(error!.localizedDescription)")
                        }
                        
                        
                    })

                    
                    alert.dismiss(animated: false, completion:nil)
                    
                    
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Disable", style: .cancel, handler: {
                    action in
                    
                    self.appManager.defaults.set(false, forKey: Preferences.TOUCH_ID_ENABLED)
                    self.appManager.defaults.set(true, forKey: Preferences.TOUCH_ID_REQUESTED)
                    
                    
                    self.appManager.keychain.delete(Preferences.USERNAME)
                    self.appManager.keychain.delete(Preferences.PASSWORD)
                    
                    UserDefaults.standard.synchronize()
                    
                    alert.dismiss(animated: true, completion: nil)
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        else {
            
        }
        
        
        if !loaded {
            loaded = true
            
            loadJobs()
        } else {
            updateUI()
        }
        
    }
    
    
    
    func pulse() {
        if pulseAnimation == nil {
            pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation?.duration = 0.3
            pulseAnimation?.toValue = NSNumber(value: 1.0)
            pulseAnimation?.toValue = NSNumber(value: 1.2)
            pulseAnimation?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            pulseAnimation?.autoreverses = true
            pulseAnimation?.repeatCount = Float.greatestFiniteMagnitude
        }
        
    }
    
    
    @IBAction func refresh() {
        loadJobs()
    }
    
    func loadJobs() {
       
        self.view.isUserInteractionEnabled = false
        self.view.makeToastActivity(.center)
        
        Requests.getAllJobs { (apiResult) in
            DispatchQueue.main.async {
                
                self.view.isUserInteractionEnabled = true
                self.view.hideToastActivity()
                
                if apiResult.userMessage != nil {
                    self.present(SimpleAlert.dismissAlert(message: apiResult.errorMessage, title: "", cancel: "OK"), animated: true, completion: nil)
                    return
                }
                guard apiResult.statusCode == 200 else{
                    
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: apiResult.data!, options: .allowFragments)
                    print("JOB : \(json)");
                    if let obj = json as? [[String:Any]],let firstObj = obj.first{
                        print(firstObj)
                    }
                }
                catch {
                }
                ParseResponse.parseJobsData(data: apiResult.data, completion: { (jobs, errorMessage) in
                   
                    
                    DispatchQueue.main.async {
                        if jobs != nil {
                            self.view.isUserInteractionEnabled = false
                            self.view.makeToastActivity(.center)
                            
                            Requests.getDriverStatusDetails(status: "") { (apiResult) in
                                DispatchQueue.main.async {
                                    self.view.hideToastActivity()
                                    self.view.isUserInteractionEnabled = true
                                    self.driverStatusSegement.isEnabled = true
                                   
                                }
                                if let code = apiResult.statusCode,code == 200,let objData = apiResult.data{
                                    do{
                                        if let objJSON = try JSONSerialization.jsonObject(with: objData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]{
                                          
                                            self.updateDriverSegementSelector(response: objJSON)
                                        }
                                    }catch{
                                        
                                    }
                                }
                            }
                            
                            AppManager.sharedInstance.allJobs = jobs!
                            JobsManager.sortJobs()
                            self.updateUI()

                        }else {
                            
                            if let _ = apiResult.userMessage{
                                self.present(SimpleAlert.dismissAlert(message: apiResult.userMessage?.rawValue ?? "unknown error", title: "", cancel: "OK"), animated: true, completion: nil)
                            }else{
//                                AppManager.sharedInstance.sessionExpired()

                            }
                        }
                    }
                })
                
                
               
            }
        }
        
    }
    func getDriverStatus(){
        self.view.isUserInteractionEnabled = false
        self.view.makeToastActivity(.center)
        
        Requests.getDriverStatusDetails(status: "") { (apiResult) in
            DispatchQueue.main.async {
                self.view.hideToastActivity()
                self.view.isUserInteractionEnabled = true
                self.driverStatusSegement.isEnabled = true
                
            }
            if let code = apiResult.statusCode,code == 200,let objData = apiResult.data{
                do{
                    if let objJSON = try JSONSerialization.jsonObject(with: objData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]{
                        
                        self.updateDriverSegementSelector(response: objJSON)
                    }
                }catch{
                    
                }
            }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to_progress" {
            if let vc = segue.destination as? MapProgressViewController{
                vc.isDefaulShowSpecialInstruction = true
            }
            
        }
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
    
    @objc func updateUI() {
        
        self.view.hideToastActivity()
        
        
        
        if appManager.currentJob != nil {
            
           
            if appManager.currentJob!.manualAppraisalRequired == 1 {
                if appManager.currentJobAppraisal!.manualAppraisal == nil || appManager.currentJobAppraisal!.manualAppraisal!.pickup.vehicleDetailSections == nil {
                    
                    VehicleDetailsManager.getVehicleDetails()
                    VehicleDetailsManager.getVehicleParts(vehicleType: appManager.currentJob!.vehicle!.type ?? "")
                }
            }
           
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let p = "\(appManager.currentJob!.pickupPreposition!.rawValue.uppercased()) \(appManager.currentJob!.getPickupDate()) \(appManager.currentJob!.pickupTime!)"
            let d = "\(appManager.currentJob!.pickupPreposition!.rawValue.uppercased()) \(appManager.currentJob!.getDropOffDate()) \(appManager.currentJob!.dropoffTime!)"
            
//            var docs : [[(String,String)]] = []
            var docs : [(String,String)] = []
            var counter = 1
            for doc in appManager.currentJob!.driverDocuments {
                docs.append(("Document \(counter)", doc.label ?? ""))
                counter += 1
            }
            
            
            content = [
                [
                    ("Special Instructions",(appManager.currentJob!.specialInstructions == nil || appManager.currentJob!.specialInstructions!.count == 0)  ? "No special instructions" : appManager.currentJob!.specialInstructions!),
                    ("Jet Wash",appManager.currentJob!.jetWashRequired == 1 ? "Jet wash IS REQUIRED" : "Jet wash is NOT required"),
                    ("Fleet Paperwork",appManager.currentJob!.fleetPaperworkRequired == 1 ? "Fleet paperwork IS REQUIRED" : "Fleet paperwork is NOT required")
                ],
                    docs
                ,
                [
                    ("Pickup",p),
                    ("Pickup Address",parseAddress(address: appManager.currentJob!.pickupAddress!)),
                    ("Opening Time","\(appManager.currentJob!.pickupAddress!.openingTime ?? "")"),
                    ("COMPOUND OPENING TIMES","\(appManager.currentJob!.pickupAddress!.compoundOpeningTime ?? "")")
                ],
                [
                    ("Dropoff",d),
                    ("Dropoff Address",parseAddress(address: appManager.currentJob!.dropoffAddress!)),
                    ("Opening Time","\(appManager.currentJob!.dropoffAddress!.openingTime ?? "")"),
                    ("COMPOUND OPENING TIMES","\(appManager.currentJob!.dropoffAddress!.compoundOpeningTime ?? "")")
                ],
                [
                    ("Type",appManager.currentJob!.vehicle!.type!),
                    ("Make",appManager.currentJob!.vehicle!.make ?? ""),
                    ("Model",appManager.currentJob!.vehicle!.model ?? ""),
                    ("Colour",appManager.currentJob!.vehicle!.colour ?? ""),
                    ("Number Plate",appManager.currentJob!.vehicle!.registrationNumber ?? ""),
                    ("VIN",appManager.currentJob!.vehicle!.vinNumber ?? ""),
                    ("Key to Key",appManager.currentJob!.keytokey ?? "")
                ],
                [
                    ("Full Name",appManager.currentJob!.customer?.contactName ?? ""),
                    ("Email",appManager.currentJob!.customer?.contactEmail ?? ""),
                    ("Number 1",appManager.currentJob!.customer?.contactTelephone1 ?? ""),
                    ("Number 2",appManager.currentJob!.customer?.contactTelephone2 ?? "")
                ]
            ]
            
            
            goToAppraisalControl.alpha = 1
            goToAppraisalControl.isUserInteractionEnabled = true
            noActiveJobView.isHidden = true
            goToAppraisalControl.isHidden = false
            completeJobView.isHidden = true
            
            
           
            Requests.getDriverCallDetails(jobID:appManager.currentJob!.id!) { (apiResult) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.view.isUserInteractionEnabled = true
               
                
                if let code = apiResult.statusCode,code == 200,let objData = apiResult.data{
                    do{
                        if let objJSON = try JSONSerialization.jsonObject(with: objData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]{
                            
                            if let callDetails = objJSON["call_details"] as? [[String:Any]]{
                                var callComponent:[(String,String)] = []
                                for detail in callDetails{
                                    if let question = detail["Question"],let answer = detail["Answer"]{
                                        callComponent.append(("\(question)","\(answer)"))
                                    }
                                }
                                if callComponent.count > 0,self.content.count == 6{
                                   // self.content.append(callComponent)
                                   // self.sectionTitles.append("Call Details")
                                }
                            }
                            DispatchQueue.main.async {
                                self.theTable.reloadData()
                            }
                        }else{
                           // self.sectionTitles.append("Call Details")
                           // self.content.append([("Confirmed on site","No")])
                            DispatchQueue.main.async {
                                self.theTable.reloadData()
                            }
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                }else{
                    //self.sectionTitles.append("Call Details")
                   // self.content.append([("Confirmed on site","No")])
                    DispatchQueue.main.async {
                        self.theTable.reloadData()
                    }
                }
                }
            }
            
            switch appManager.currentJobAppraisal!.status {
            case .accepted:
                jobStatusLabel.text = "Start Appraisal".uppercased()
                break
            case .pickupAppraisalStarted:
                jobStatusLabel.text = "Continue Appraisal".uppercased()
                break
            case .pickupAppraisalComplete:
                jobStatusLabel.text = "Start Driving".uppercased()
                break
            case .driving, .dropoffAppraisalStarted, .dropoffAppraisalComplete:
                jobStatusLabel.text = "Continue Driving".uppercased()
                break
            case .completed, .completedAwaitingData:
                goToAppraisalControl.isHidden = true
                completeJobView.isHidden = false
                break;
            default:
                jobStatusLabel.text = "Continue Job".uppercased()
            }
        }
        else {
            goToAppraisalControl.alpha = 0
            goToAppraisalControl.isUserInteractionEnabled = false
            noActiveJobView.isHidden = false
            completeJobView.isHidden = true
        }
        
        theTable.reloadData()
        theTable.allowsSelection = true
        

        lblNumberOfJobsToReview.text = "\(appManager.inactiveJobs.count + appManager.activeJobs.count)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func driverStatusUpdateSelector(sender:UISegmentedControl){
        self.view.isUserInteractionEnabled = false
        self.view.makeToastActivity(.center)
        
        Requests.getDriverStatusDetails(status: "\(sender.selectedSegmentIndex)") { (apiResult) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.view.isUserInteractionEnabled = true
                }
            
            if let code = apiResult.statusCode,code == 200,let objData = apiResult.data{
                do{
                    if let objJSON = try JSONSerialization.jsonObject(with: objData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]{
                        print("JSON Driver Status :- \(objJSON)")
                        self.updateDriverSegementSelector(response: objJSON)
                    }
                }catch{
                    
                }
            }
        }
    }
    func updateDriverSegementSelector(response:[String:Any]){
        if let status = response["active"],let isActiveStatus = "\(status)".bool{
            DispatchQueue.main.async {
                self.driverStatusSegement.selectedSegmentIndex = (isActiveStatus) ? 1 : 0
            }
            
        }
    }
    @IBAction func continueJob() {
        
        switch appManager.currentJobAppraisal!.status {
        case .driving, .dropoffAppraisalStarted, .dropoffAppraisalComplete:
            self.performSegue(withIdentifier: "to_progress", sender: nil)
            break;
        default:
            self.performSegue(withIdentifier: "to_job", sender: nil)
        }
        
        
        
    }
    @IBAction func expenseTrailSelector(sender:UIButton){
        if let expenseViewController = self.storyboard?.instantiateViewController(withIdentifier: "ExpenseTrailViewController") as? ExpenseTrailViewController{
            self.navigationController?.pushViewController(expenseViewController, animated: true)
        }
    }
    @IBAction func wagesSelector(sender:UIButton){
        self.checkDriverWages()
    }
    //MARK:  API Methods
    func checkDriverWages() {
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = false
            self.view.makeToastActivity(.center)
                   
        }
        
        Requests.getUnnapprovedWages() { (response) in
            DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.view.hideToastActivity()
             }
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
                                }
                                
                            }
                        }
                        else {
                        }
                        
                        
                    }
                    catch let error {
                        print("Wages Parsing Error: \(error.localizedDescription)")
                        let exception = NSException(name:NSExceptionName(rawValue: "checkDriverWages"),
                                                    reason:"\(error.localizedDescription)",
                            userInfo:nil)
                        Bugsnag.notify(exception)
                    }
                }
                
            }
        }
    }
    //MARK:  UITABLEVIEW Delegtes and datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (appManager.currentJob == nil){ return 0}
        return content.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (appManager.currentJob == nil) {return 0}
        return content[section].count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DashCell
        cell.backgroundColor = .clear
        
        if  indexPath.section == 0 {
        
            if indexPath.row == 0 {
                if appManager.currentJob!.specialInstructions != nil && appManager.currentJob!.specialInstructions!.count > 0 {
                    cell.backgroundColor = UIColor(red: 1.0, green: 252/255.0, blue: 121/255.0, alpha: 1.0)
                }
        
            }
            else if indexPath.row == 1 {
                if appManager.currentJob!.jetWashRequired == 1 {
                    cell.backgroundColor = UIColor(red: 1.0, green: 252/255.0, blue: 121/255.0, alpha: 1.0)
                }
                
            }
            else if indexPath.row == 2 {
                if appManager.currentJob!.fleetPaperworkRequired == 1 {
                    cell.backgroundColor = UIColor(red: 1.0, green: 252/255.0, blue: 121/255.0, alpha: 1.0)
                }
                
            }
            
            
        }
        
        
        cell.lblTitle.text = content[indexPath.section][indexPath.row].0.uppercased()
        cell.lblDescription.text = content[indexPath.section][indexPath.row].1
        
        return cell
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DashCell
        
        let _ = cell.lblTitle.text
        if  indexPath.section == 0 {
            
            if indexPath.row == 0 {
                if appManager.currentJob!.specialInstructions != nil && appManager.currentJob!.specialInstructions!.count > 0 {
                    let strMessage = (appManager.currentJob!.specialInstructions == nil || appManager.currentJob!.specialInstructions!.count == 0)  ? "No special instructions" : appManager.currentJob!.specialInstructions!
                    let alertViewController = UIAlertController.init(title: "Special Instructions".uppercased(), message: "\(strMessage)", preferredStyle: .alert)
                    let alertAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: { (_) in
                        
                    })
                    alertViewController.addAction(alertAction)
                    if appManager.currentJob!.specialInstructions != nil && appManager.currentJob!.specialInstructions!.count > 0 {
                        alertViewController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 1.0, green: 252/255.0, blue: 121/255.0, alpha: 1.0)
                    }
                    alertViewController.view.tintColor = UIColor.lightGray
                    self.present(alertViewController, animated: true, completion: nil)
                    
                }
                
            }
        }
        /*let result = appManager.currentJob!.driverDocuments.filter{
            return $0.label ?? "".lowercased() == text ?? "".lowercased()
        }*/
        if indexPath.section == 1,appManager.currentJob!.driverDocuments.count > indexPath.row{
             let doc = appManager.currentJob!.driverDocuments[indexPath.row]
                //is a document
                if let fileName = doc.filename, let url = URL(string: ApiConstants.BASE_URL + fileName)  {
                    //a valid path exists
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                else {
                    self.view.makeToast("No valid file path detected", duration: 1.5, position: .center)
                }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        view.backgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
        
        let lbl = UILabel(frame: CGRect(x: 8, y: 10, width: tableView.frame.size.width-16, height: 20))
        lbl.backgroundColor = UIColor.clear
        lbl.font = UIFont(name: "JosefinSans-Bold", size: 18)
        lbl.text = sectionTitles[section].uppercased()
        view.addSubview(lbl)
        
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension DashViewController:MessagePopupDelegate{
    func finishedCheckingMessages() {
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
              //the delay is just to make sure the message popup has finished dismissing
              self.checkDriverWages()
          })
          
      }
    func finishedCheckingDriverWages() {
//        self.inUploadCycle = false
//        OfflineFolderStructure.checkFoldersForDeletion()
    }
    
}





extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return nil
        }
    }
}





