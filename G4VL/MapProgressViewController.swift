//
//  MapProgressViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 26/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import MapKit
import Bugsnag
class RoundButton:UIButton{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = self.bounds.size.height/2
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        
    }
}
class MapProgressViewController: UIViewController, MKMapViewDelegate, SlideSwitchDelegate, AppraisalViewDelegate {
    
    let appManager = AppManager.sharedInstance
    @IBOutlet var myMap : MKMapView!
    @IBOutlet var slideSwitch : SlideSwitch!
    @IBOutlet var lblAddress : UILabel!
    
    @IBOutlet var jetWashView : UIView!
    
    @IBOutlet var expensesControl : AppraisalView!
    @IBOutlet var appraisalControl : AppraisalView!
    

    let point1 = MKPointAnnotation()
    let point2 = MKPointAnnotation()

    var myRoute : MKRoute!
    
    @IBOutlet var viewSpecialInstruction:UIView!
    @IBOutlet var txtSpecialInstruction:UITextView!
    var isDefaulShowSpecialInstruction:Bool = false
    
    @IBAction func home() {
        self.navigationController?.popToViewController(appManager.homeVC!, animated: true)
    }
    
    func parseAddress(address:Address) -> String {
        
        var string = ""
        
        if address.addressLine1 != nil {
            string += address.addressLine1! + ", "
        }
        if address.addressLine1 != nil {
            string += address.addressLine1! + ", "
        }
        if address.addressLine2 != nil {
            string += address.addressLine2! + ", "
        }
        if address.townCity != nil {
            string += address.townCity! + ", "
        }
        if address.countyArea != nil {
            string += address.countyArea! + ", "
        }
        
        string += (address.postcode ?? "")
        
        return string
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if slideSwitch.lockedIn {
            slideSwitch.reset()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        slideSwitch.delegate = self
        
        lblAddress.text = parseAddress(address: appManager.currentJob!.dropoffAddress!)
        
        
        updateProgress()
        
        expensesControl.setContent(icon: #imageLiteral(resourceName: "apple_100"), title: "Expenses", required: true, complete: false, fadeWhenInComplete: false)
        appraisalControl.setContent(icon: #imageLiteral(resourceName: "appraisal"), title: "Drop Off Appraisal", required: true, complete: false, fadeWhenInComplete: false)
        
        expensesControl.delegate = self
        appraisalControl.delegate = self
     
        txtSpecialInstruction.text = AppManager.sharedInstance.currentJob!.specialInstructions ?? "No special instructions"

        self.setupMap()
        
        self.viewSpecialInstruction.isHidden = !self.isDefaulShowSpecialInstruction
    }
    
    
    
    func setupMap() {
        
        let long1 = (appManager.currentJob!.pickupAddress!.long! as NSString).doubleValue
        let latt1 = (appManager.currentJob!.pickupAddress!.latt! as NSString).doubleValue
        
        let long2 = (appManager.currentJob!.dropoffAddress!.long! as NSString).doubleValue
        let latt2 = (appManager.currentJob!.dropoffAddress!.latt! as NSString).doubleValue
        
        
        
        point1.coordinate = CLLocationCoordinate2DMake(latt1, long1)
        
        myMap.addAnnotation(point1)
        
        point2.coordinate = CLLocationCoordinate2DMake(latt2, long2)
        
        myMap.addAnnotation(point2)
        myMap.centerCoordinate = point2.coordinate
        myMap.delegate = self
        
        //Span of the map
        
        myMap.setRegion(MKCoordinateRegion(center: point2.coordinate, span: MKCoordinateSpan(latitudeDelta: 1,longitudeDelta: 1)), animated: true)
        
        let directionsRequest = MKDirections.Request()
        
        let mark1 = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point1.coordinate.latitude, point1.coordinate.longitude), addressDictionary: nil)
        
        let mark2 = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point2.coordinate.latitude, point2.coordinate.longitude), addressDictionary: nil)
        
        directionsRequest.source = MKMapItem(placemark: mark1)
        directionsRequest.destination = MKMapItem(placemark: mark2)
        
        directionsRequest.transportType = MKDirectionsTransportType.automobile
        
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculate(completionHandler: {
            
            response, error in
            
            if error == nil {
                
                self.myRoute = response!.routes[0] as MKRoute
                
                self.myMap.addOverlay(self.myRoute.polyline)
                
                if let first = self.myMap.overlays.first {
                    let rect = self.myMap.overlays.reduce(first.boundingMapRect, {$0.union($1.boundingMapRect)})
                    self.myMap.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
                }
                
            }
        })
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) ->MKOverlayRenderer {
        
        let myLineRenderer = MKPolylineRenderer(polyline: myRoute.polyline)
        
        myLineRenderer.strokeColor = UIColor.red
        
        myLineRenderer.lineWidth = 3
        
        return myLineRenderer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openAppleMaps() {
        
        if let url = URL(string: "http://maps.apple.com/?saddr=\(point1.coordinate.latitude),\(point1.coordinate.longitude)&daddr=\(point2.coordinate.latitude),\(point2.coordinate.longitude)") {
            UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey(rawValue: UIApplication.OpenURLOptionsKey.sourceApplication.rawValue) : "" ], completionHandler: {
                finished in
                
            })
        }
        
        
        
    }
    
    @IBAction func openGoogleMaps() {
        if let url = URL(string: "http://maps.google.com/?saddr=\(point1.coordinate.latitude),\(point1.coordinate.longitude)&daddr=\(point2.coordinate.latitude),\(point2.coordinate.longitude)") {
            UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey(rawValue: UIApplication.OpenURLOptionsKey.sourceApplication.rawValue) : "" ], completionHandler: {
                finished in
                
                
            })
        }
    }
    @IBAction func buttonSpecialInstrictionCloseSelctor(sender:UIButton){
        self.viewSpecialInstruction.isHidden = true
    }
    @IBAction func buttonSpecialInstrictionOpenSelctor(sender:UIButton){
        self.viewSpecialInstruction.isHidden = false
    }
    func updateProgress() {
        let jetRequired = (appManager.currentJob!.jetWashRequired != nil && appManager.currentJob!.jetWashRequired == 1)
       
        if !jetRequired {
            jetWashView.removeFromSuperview()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "to_appraisal" {
            let vc = segue.destination as! JobViewController
            vc.pickup = false
        }
       
    }
    
    
    func tapped(appraisalView: AppraisalView) {
        if appraisalView == expensesControl {
            self.performSegue(withIdentifier: "to_expenses", sender: nil)
        }
        else if appraisalView == appraisalControl {
            self.performSegue(withIdentifier: "to_appraisal", sender: nil)
        }
    }
    
    
    @IBAction func jetWashAction(control:UIControl) {
        if control.alpha < 1.0 {
            self.view.makeToast("Jet wash is not required", duration: 1.5, position: .center)
            return
        }
        
        self.performSegue(withIdentifier: "to_expenses", sender: nil)
    }
    
    func showJetWashAlert()->Bool {
        
        if appManager.currentJob!.jetWashRequired == 0 {
            return false
        }
        
        if appManager.currentJobAppraisal!.noJetWashReason != nil && appManager.currentJobAppraisal!.noJetWashReason!.count > 0 {
            return false
        }
        
        for expense in appManager.currentJobAppraisal!.expenses {
            if expense.isJetWash {
                return false
            }
        }
        
        return true
    }
    
    func showJetWashSkip() {
        var txt : UITextField?
        
        let alert = UIAlertController(title: "Jet Wash", message: "Please specifiy the reason for skipping Jet Wash.", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {
            textfield in
            txt = textfield
            txt?.enablesReturnKeyAutomatically = false
            
        })
        
        alert.addAction(UIAlertAction(title: "Skip", style: .default, handler: {
            action in
            
            if txt!.text!.trimmingCharacters(in: .whitespaces).count > 0 {
                
               self.appManager.currentJobAppraisal!.noJetWashReason = txt!.text!.trimmingCharacters(in: .whitespaces)
                JobsManager.saveJobAppraisal(job: self.appManager.currentJobAppraisal!, saveExpenses: false)
                
                alert.dismiss(animated: true, completion: nil)
                self.slid()
            }
            else {
                let alert1 = UIAlertController(title: "No Reason", message: "You must enter a reason for skipping jet wash", preferredStyle: .alert)
                
                alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    action in
                    
                    
                    alert1.dismiss(animated: true, completion: nil)
                    self.showJetWashSkip()
                    
                }))
                
                alert1.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    action in
                    
                    
                    self.slideSwitch.reset()
                    alert1.dismiss(animated: true, completion: nil)
                    
                    
                }))
                
                self.present(alert1, animated: true, completion: nil)
            }
            
        }))
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            
            
            self.slideSwitch.reset()
            alert.dismiss(animated: true, completion: nil)
            
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
   
    
    func slid() {
        
        if showJetWashAlert() {

            let alert = UIAlertController(title: nil, message: "Jet wash is required for this job. Please add your receipt in expenses.", preferredStyle: .alert)


            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.slideSwitch.reset()
            }))
            
            alert.addAction(UIAlertAction(title: "Skip", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.showJetWashSkip()
            }))

            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if appManager.currentJobAppraisal!.signatures!.dropoff == nil || appManager.currentJobAppraisal!.signatures!.dropoff!.dateSigned == nil {
            
            let alert = UIAlertController(title: nil, message: "Please complete the dropoff appraisal before completing the job.", preferredStyle: .alert)
            
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
            slideSwitch.reset()
            return
        }
        
        let alert = UIAlertController(title: "Expenses", message: "Please confirm you have added all of your expenses.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            
            self.view.isUserInteractionEnabled = false
            self.view.makeToastActivity(.center)
            
            self.appManager.currentJobAppraisal!.status = .completed
            //self.appManager.currentJobAppraisal!.status = .completedAwaitingData
            
            Requests.changeJobStatus(jobID: self.appManager.currentJobAppraisal!.jobID!, status: .completed)
            //Requests.changeJobStatus(jobID: self.appManager.currentJobAppraisal!.jobID!, status: .completedAwaitingData)
            
            JobsManager.generatePODSFile(job: self.appManager.currentJobAppraisal!, completion: {
                (url, error) in
                
                
                if url != nil {
                    
                    do {
                        let data = try Data(contentsOf: url!)
                        Requests.pushAppraisalWithCompletion(jobID: AppManager.sharedInstance.currentJobAppraisal!.jobID!, appraisal: data, completion: { (success) in
                            if success{
                                let path = OfflineFolderStructure.getDriverPath(id: AppManager.sharedInstance.currentUser!.driverID!)
                                
                                let fileManager = FileManager.default
                                do {
                                    let folderURLS = try fileManager.contentsOfDirectory(at: URL(string:path)!, includingPropertiesForKeys: nil)
                                    if folderURLS.count > 0{
                                        for folderURL in folderURLS{
                                            let jobID = (folderURL.lastPathComponent.replacingOccurrences(of: "job_", with: "") as NSString).integerValue
                                            if AppManager.sharedInstance.currentJobAppraisal!.jobID! == jobID{
                                                self.deleteFolder(path: folderURL.absoluteString.trimmingCharacters(in: .punctuationCharacters))
                                            }
                                        }
                                    }
                                }catch{
                                    
                                }
                            }
                        })
                        //Requests.pushAppraisal(jobID: self.appManager.currentJobAppraisal!.jobID!, appraisal: data)
                    }
                    catch {
                        let exception = NSException(name:NSExceptionName(rawValue: "slid"),
                                                    reason:"\(error.localizedDescription)",
                            userInfo:nil)
                        Bugsnag.notify(exception)
                    }
                }
                
                
                
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    
                    self.appManager.activeJobs = self.appManager.activeJobs.filter {
                        return $0.status != .completed && $0.status != .completedAwaitingData
                    }
                    self.view.hideToastActivity()
                    self.performSegue(withIdentifier: "to_finish", sender: nil)
                }
                
            })
            

        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.slideSwitch.reset()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    private func deleteFolder(path:String) {
        
        
        
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
