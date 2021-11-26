//
//  JobViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 21/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import Toast_Swift
import CoreLocation
import Bugsnag

class JobViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NumberPlateHeaderViewDelegate {
    
    
    enum Item {
        case video, manual, mileage, petrol, warningLight, extras, signature, startDriving, fleet, specialInstructions
        
        var pickupIndex : Int {
            switch self {
            case .video:
                return 0
            case .manual:
                return 1
            case .mileage:
                return 2
            case .petrol:
                return 3
            case .warningLight:
                return 4
            case .signature:
                return 5
            case .startDriving:
                return 6
           /*case .extras:
                return 5
            case .signature:
                return 6
            case .startDriving:
                return 7*/
            default:
                return -1
            }
        }
        var dropoffIndex : Int {
            
            switch self {
            case .video:
                return 0
            case .manual:
                return 1
            case .mileage:
                return 2
            case .petrol:
                return 3
            case .warningLight:
                return 4
            case .fleet:
                return 5
            case .specialInstructions:
                return 6
            case .signature:
                return 7
                /*
            case .extras:
                return 5
            case .fleet:
                return 6
            case .specialInstructions:
                return 7
            case .signature:
                return 8
                 */
            default:
                return -1
            }
            
        }
        
        static let pickupTotal = 7
        static let dropoffTotal = 8
    }
    
    
    enum Progress  {
        case numberPlate, vin, video, manual, mileage, petrol, warningLight, extras, signature, startDriving, fleet, specialInstructions
    }
    
    var appManager = AppManager.sharedInstance
    @IBOutlet var collectionView : UICollectionView!
    var pickup = true
    
    
    
    var jobAppraisal : JobAppraisal {
        return AppManager.sharedInstance.currentJobAppraisal!
    }
    var job : Job {
        return AppManager.sharedInstance.currentJob!
    }
    var proccess:Progress = .numberPlate
    
    var currentProgress : Progress{
        get{
            return proccess
        }
        set{
            self.proccess = newValue
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    /*= .numberPlate {
        didSet {
            /*
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }*/
            print(currentProgress)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.collectionView.reloadData()
            }
        }
    }
    */
    var external = false
    var itemSize : CGSize?
    var currentItem : IndexPath?
    
    
    @IBOutlet var lblTitle : UILabel!

    var pulseAnimation:CABasicAnimation?
    var scanimation:CABasicAnimation?
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
      
        
        lblTitle.text = "JOB \(job.id!)"
       
        if job.manualAppraisalRequired == 1 {
            
            if jobAppraisal.manualAppraisal == nil || jobAppraisal.manualAppraisal!.pickup.vehicleDetailSections == nil {
                VehicleDetailsManager.getVehicleDetails()
            }
            
            if jobAppraisal.manualAppraisal == nil || jobAppraisal.manualAppraisal!.pickup.vehicleParts == nil {
                VehicleDetailsManager.getVehicleParts(vehicleType: job.vehicle!.type ?? "")
            }
            
            VehiclePartAnalysis.loadAppraisalProgress(pickup: pickup)
            
        }
       
        
        DispatchQueue.main.async {
            self.setup()

            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.view.hideToastActivity()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if currentItem != nil {
            collectionView.scrollToItem(at: currentItem!, at: .centeredVertically, animated: true)
            currentItem = nil
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        itemSize = CGSize(width: (collectionView.frame.size.width - 24) / 2, height: 200)
        DispatchQueue.main.async {
            self.updateProgress()
        }
    }
    
    func setup() {
        collectionView.contentInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)//UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "AppraisalCell", bundle: nil), forCellWithReuseIdentifier: "AppraisalCell")
        collectionView.register(UINib(nibName: "NumberPlateHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "NumberPlateHeaderView")
        
    
        //external = job.appraisalToBeDoneOnExternalSystem == 1
    }
    
    
    func updateProgress() {
        
        if job.vehicle!.registrationNumber != nil {
            // number Plate present
            if !numberPlateStageComplete() {
                //number plate
                currentItem = nil

                currentProgress = .numberPlate
                return
            }
        }
        else {
            if !vinStageComplete() {
                currentItem = nil
                currentProgress = .vin
                return
            }
        }
        if !hasCompletedVideoAppraisal() {
            currentItem = nil

            currentProgress = .video
            return
        }
        if !hasCompletedManualAppraisal() {
            currentItem = nil

            currentProgress = .manual
            return
        }
        if !hasCompletedMileageCheck() {
            
            if pickup {
                currentItem = IndexPath(item: Item.mileage.pickupIndex, section: 0)
            }
            else {
                currentItem = IndexPath(item: Item.mileage.dropoffIndex, section: 0)
            }
            currentProgress = .mileage
            return
        }
        if !hasCompletedPetrolCheck() {
            
            if pickup {
                currentItem = IndexPath(item: Item.petrol.pickupIndex, section: 0)
            }
            else {
                currentItem = IndexPath(item: Item.petrol.dropoffIndex, section: 0)
            }
            currentProgress = .petrol
            return
        }
        if !hasCompletedWarningLightsCheck() {
            
            if pickup {
                currentItem = IndexPath(item: Item.warningLight.pickupIndex, section: 0)
            }
            else {
                currentItem = IndexPath(item: Item.warningLight.dropoffIndex, section: 0)
            }
            currentProgress = .warningLight
            return
        }
        /*
        if !hasCompletedExtrasCheck() {
            
            if pickup {
                currentItem = IndexPath(item: Item.extras.pickupIndex, section: 0)
            }
            else {
                currentItem = IndexPath(item: Item.extras.dropoffIndex, section: 0)
            }
            currentProgress = .extras
            return
        }
        */
        if !pickup {
            if !hasCompletedPaperworkCheck() {
                
                
                currentItem = IndexPath(item: Item.fleet.dropoffIndex, section: 0)
                currentProgress = .fleet
                return
            }
            if !hasCompleteSpecialInstructions() {
                
               currentItem = IndexPath(item: Item.specialInstructions.dropoffIndex, section: 0)
                currentProgress = .specialInstructions
                return
            }
        }
        
        if !hasCompletedSignature() {
            
            if pickup {
                currentItem = IndexPath(item: Item.signature.pickupIndex, section: 0)
            }
            else {
                currentItem = IndexPath(item: Item.signature.dropoffIndex, section: 0)
            }
            currentProgress = .signature
            return
        }
        
        currentProgress = .startDriving
    
    }

    
    //MARK: CollectionView Delegate/DataSource
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView : NumberPlateHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "NumberPlateHeaderView", for: indexPath) as! NumberPlateHeaderView
        headerView.delegate = self
        headerView.frame.size.height = itemSize!.height
        
        
        if job.vehicle!.registrationNumber != nil {
            
            var entry : Entry = .nothing
            
            if pickup {
                entry = jobAppraisal.numberPlate!.pickup.entry
            }
            else {
               entry = jobAppraisal.numberPlate!.dropoff.entry
            }
            
            var scanString = ""
            switch entry {
            case .nothing:
                scanString = "Scan Plate"
            case .scanned:
                scanString = "Plate Scanned"
            case .manual:
                scanString = "Plate Entered"
            case .skipped:
                scanString = "Plate Skipped"
            }
            headerView.setContent(scanLabelString: scanString, regLabelString: job.vehicle!.registrationNumber!.uppercased())
        }
        else {
            
            var entry : Entry = .nothing
            
            if pickup {
                entry = jobAppraisal.vin!.pickup.entry
            }
            else {
                entry = jobAppraisal.vin!.dropoff.entry
            }
            
            var scanString = ""
            switch entry {
            case .manual:
                scanString = "VIN Entered"
            case .skipped:
                scanString = "VIN Skipped"
            default:
                scanString = "Enter VIN"
            }
            headerView.setContent(scanLabelString: scanString, regLabelString: job.vehicle!.vinNumber!.uppercased())
        }
        
        headerView.invert(currentProgress == .numberPlate || currentProgress == .vin)
        
        
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 16, height: itemSize!.height)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pickup {
            return Item.pickupTotal
        }else{
            return Item.dropoffTotal
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : AppraisalCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppraisalCell", for: indexPath) as! AppraisalCell
        
        
        if pickup {
            switch indexPath.row {
            case Item.video.pickupIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "phone_100"),
                    title: "Video Appraisal",
                    required: job.videoAppraisalRequired == 1,
                    complete: hasCompletedVideoAppraisal(),
                    fadeWhenInComplete: true,
                    externalSystemName: nil
                )
                cell.invert(currentProgress == .video )
                return cell
               // break;
            case Item.manual.pickupIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "hand_100"),
                    title: "Manual Appraisal",
                    required: job.manualAppraisalRequired == 1,
                    complete: hasCompletedManualAppraisal(),
                    fadeWhenInComplete: true,
                    externalSystemName: nil//job.appraisalToBeDoneOnExternalSystem == 1 ? job.nameOfExternalSystemForAppraisal ?? "" : nil
                )
                cell.invert(currentProgress == .manual )
                return cell
               // break;
            case Item.mileage.pickupIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "mileage_100"),
                    title: "Mileage",
                    required: true,
                    complete: hasCompletedMileageCheck(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .mileage )
                  return cell
               // break;
            case Item.petrol.pickupIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "petrol_100"),
                    title: "Petrol Level",
                    required: true,
                    complete: hasCompletedPetrolCheck(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .petrol )
                return cell
                //break;
            case Item.warningLight.pickupIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "warning"),
                    title: "Warning Lights",
                    required: true,
                    complete: hasCompletedWarningLightsCheck(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .warningLight )
                return cell
                //break;
            /*case Item.extras.pickupIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "extras"),
                    title: "Extras",
                    required: true,
                    complete: hasCompletedExtrasCheck(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .extras )
                break;*/
            case Item.signature.pickupIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "sign"),
                    title: "Signature",
                    required: true,
                    complete: hasCompletedSignature(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .signature )
                return cell
                //break;
            case Item.startDriving.pickupIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "car"),
                    title: "Start Drving",
                    required: true,
                    complete: false,
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .startDriving )
                return cell
                //break;
            default:
                break;
            }
        } else {
            switch indexPath.row {
            case Item.video.dropoffIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "phone_100"),
                    title: "Video Appraisal",
                    required: job.videoAppraisalRequired == 1,
                    complete: hasCompletedVideoAppraisal(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .video )
                return cell
                //break;
            case Item.manual.dropoffIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "hand_100"),
                    title: "Manual Appraisal",
                    required: job.manualAppraisalRequired == 1,
                    complete: hasCompletedManualAppraisal(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .manual )
                return cell
                //break;
            case Item.mileage.dropoffIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "mileage_100"),
                    title: "Mileage",
                    required: true,
                    complete: hasCompletedMileageCheck(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .mileage )
                return cell
                //break;
            case Item.petrol.dropoffIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "petrol_100"),
                    title: "Petrol Level",
                    required: true,
                    complete: hasCompletedPetrolCheck(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .petrol )
                return cell
                //break;
            case Item.warningLight.dropoffIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "warning"),
                    title: "Warning Lights",
                    required: true,
                    complete: hasCompletedWarningLightsCheck(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .warningLight )
                return cell
                //break;
            case Item.fleet.dropoffIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "paperwork"),
                    title: "Paperwork",
                    required: (job.fleetPaperworkRequired != nil && job.fleetPaperworkRequired! == 1),
                    complete: hasCompletedPaperworkCheck(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .fleet )
                return cell
                //break;
            case Item.specialInstructions.dropoffIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "instructions"),
                    title: "Special Instructions",
                    required: (job.specialInstructions != nil && job.specialInstructions!.count > 0),
                    complete: hasCompleteSpecialInstructions(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .specialInstructions )
                return cell
                //break;
                /*
            case Item.extras.dropoffIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "extras"),
                    title: "Extras",
                    required: true,
                    complete: hasCompletedExtrasCheck(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .extras )
                break;*/
            case Item.signature.dropoffIndex:
                cell.setContent(
                    icon: #imageLiteral(resourceName: "sign"),
                    title: "Signature",
                    required: true,
                    complete: hasCompletedSignature(),
                    fadeWhenInComplete: true
                )
                cell.invert(currentProgress == .signature )
                return cell
                //break;
            default:
                break;
            }
        }
         return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return CGSize.init(width: UIScreen.main.bounds.width*0.5-10.0, height: UIScreen.main.bounds.width*0.5-10.0)//itemSize!

    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)!
        
        if pickup {
            switch indexPath.row  {
            case Item.video.pickupIndex:
                videoAppraisal(cell: cell)
                break;
            case Item.manual.pickupIndex:
                manualAppraisal(cell: cell)
                break;
            case Item.mileage.pickupIndex:
                mileage(cell: cell)
                break;
            case Item.petrol.pickupIndex:
                petrolLevel(cell: cell)
                break;
            case Item.warningLight.pickupIndex:
                warningLights(cell: cell)
                break;
            /*case Item.extras.pickupIndex:
                extras(cell: cell)
                break;*/
            case Item.signature.pickupIndex:
                signature(cell: cell)
                break;
            case Item.startDriving.pickupIndex:
                startJob(cell: cell)
                break;
            default:
                break;
            }
        }
        else {
            switch indexPath.row  {
            case Item.video.dropoffIndex:
                videoAppraisal(cell: cell)
                break;
            case Item.manual.dropoffIndex:
                manualAppraisal(cell: cell)
                break;
            case Item.mileage.dropoffIndex:
                mileage(cell: cell)
                break;
            case Item.petrol.dropoffIndex:
                petrolLevel(cell: cell)
                break;
            case Item.warningLight.dropoffIndex:
                warningLights(cell: cell)
                break;
            /*case Item.extras.dropoffIndex:
                extras(cell: cell)
                break;*/
            case Item.signature.dropoffIndex:
                signature(cell: cell)
                break;
            case Item.startDriving.dropoffIndex:
                startJob(cell: cell)
                break;
            case Item.specialInstructions.dropoffIndex:
                specialInstruction(cell: cell)
                break;
            case Item.fleet.dropoffIndex:
                paperwork(cell: cell)
                break;
            default:
                break;
            }
        }
    }
    
    
    //MARK: Completion Tests
    
    func numberPlateStageComplete()->Bool {
        if pickup {
            return jobAppraisal.numberPlate!.pickup.entry != .nothing
        }else{
            return jobAppraisal.numberPlate!.dropoff.entry != .nothing
        }
    }
    
    func vinStageComplete()->Bool {
        if pickup {
            return jobAppraisal.vin!.pickup.entry != .nothing
        }else{
            return jobAppraisal.vin!.dropoff.entry != .nothing
        }
    }
    
    
    func hasCompletedVideoAppraisal()->Bool {
        
        if job.appraisalToBeDoneOnExternalSystem == 1 {
            return true
        }
        
        if pickup {
            if job.videoAppraisalRequired == 1 && (jobAppraisal.videoAppraisal == nil || !jobAppraisal.videoAppraisal!.pickup.complete) {
                return false
            }
        }else {
            if job.videoAppraisalRequired == 1 && (jobAppraisal.videoAppraisal == nil || !jobAppraisal.videoAppraisal!.dropoff.complete) {
                return false
            }
        }
        return true
    }
    
    func hasCompletedManualAppraisal()->Bool {
        
        if job.appraisalToBeDoneOnExternalSystem == 1 {
            return true
        }
        
        if pickup {
            if job.manualAppraisalRequired == 1 && ((jobAppraisal.manualAppraisal == nil  || (jobAppraisal.manualAppraisal != nil && !jobAppraisal.manualAppraisal!.pickup.complete))) {
                return false
            }
        }
        else {
            if job.manualAppraisalRequired == 1 && ((jobAppraisal.manualAppraisal == nil  || (jobAppraisal.manualAppraisal != nil && !jobAppraisal.manualAppraisal!.dropoff.complete))) {
                return false
            }
        }
        
        return true
    }
    
    func hasCompletedPetrolCheck()->Bool {
        if pickup {
            if jobAppraisal.petrolLevel == nil || !jobAppraisal.petrolLevel!.pickup.complete {
                return false
            }
        }
        else {
            if jobAppraisal.petrolLevel == nil || !jobAppraisal.petrolLevel!.dropoff.complete {
                return false
            }
        }
        
        return true
    }
    
    func hasCompletedMileageCheck()->Bool {
        if pickup {
            if jobAppraisal.mileage == nil || !jobAppraisal.mileage!.pickup.complete {
                return false
            }
        }
        else {
            if jobAppraisal.mileage == nil || !jobAppraisal.mileage!.dropoff.complete {
                return false
            }
        }
        return true
    }

    func hasCompletedWarningLightsCheck()->Bool {
        if pickup {
            if jobAppraisal.warningLight == nil || !jobAppraisal.warningLight!.pickup.complete {
                return false
            }
        }
        else {
            if jobAppraisal.warningLight == nil || !jobAppraisal.warningLight!.dropoff.complete {
                return false
            }
        }
        return true
    }

    func hasCompletedExtrasCheck()->Bool {
        
        if jobAppraisal.extras == nil {
            return false
        }
        
        if pickup {
            return jobAppraisal.extras!.pickup.complete
        }
        return jobAppraisal.extras!.dropoff.complete
    }
    
    func hasCompleteSpecialInstructions()->Bool {
        
        if job.specialInstructions == nil || job.specialInstructions!.count == 0 {
            return true
        }
        if jobAppraisal.specialInstructionsComplete == nil {
            return false
        }
        
        return jobAppraisal.specialInstructionsComplete!
    }
    
    func hasCompletedPaperworkCheck()->Bool {
        
        if job.fleetPaperworkRequired == nil || job.fleetPaperworkRequired! == 0 {
            return true
        }
        
        if jobAppraisal.paperwork == nil {
            return false
        }
        
        return jobAppraisal.paperwork!.complete
    }
    
    func hasCompletedSignature()->Bool {
        
        if pickup {
            if jobAppraisal.signatures == nil || jobAppraisal.signatures!.pickup == nil {
                return false
            }
            return jobAppraisal.signatures!.pickup!.dateSigned != nil
        }
        else {
            if jobAppraisal.signatures == nil || jobAppraisal.signatures!.dropoff == nil {
                return false
            }
            return jobAppraisal.signatures!.dropoff!.dateSigned != nil
        }
        
        
        
    }

    //MARK: Actions
    func tappedHeader() {
        scanner()
    }
    
    func scanner() {
        
        if job.vehicle!.registrationNumber != nil {
            self.performSegue(withIdentifier: "to_scanner", sender: nil)
        }
        else {
            
            var txt : UITextField?
            
            let alert = UIAlertController(title: "Enter VIN", message: nil, preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: {
                textfield in
                txt = textfield
                txt?.enablesReturnKeyAutomatically = false
                txt?.autocapitalizationType = .allCharacters
                
            })
            
            alert.addAction(UIAlertAction(title: "Skip", style: .default, handler: {
                action in
                
                self.presentSkipAlert()
                
                alert.dismiss(animated: false, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {
                action in
                
                let trimmed = txt!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if self.job.vehicle!.vinNumber?.uppercased() == trimmed.uppercased() {
                    
                    if self.pickup {
                        self.jobAppraisal.vin!.pickup.entry = .manual
                        self.jobAppraisal.vin!.pickup.reasonForSkipping = ""
                    }
                    else {
                        self.jobAppraisal.vin!.dropoff.entry = .manual
                        self.jobAppraisal.vin!.dropoff.reasonForSkipping = ""
                    }
                    
                    if self.pickup {
                        self.jobAppraisal.status = .pickupAppraisalStarted
                        JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                        Requests.changeJobStatus(jobID: self.jobAppraisal.jobID!, status: .pickupAppraisalStarted)
                    }
                    else {
                        self.jobAppraisal.status = .dropoffAppraisalStarted
                        JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                        Requests.changeJobStatus(jobID: self.jobAppraisal.jobID!, status: .dropoffAppraisalStarted)
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    
                }
                else {
                    
                    let alert1 = UIAlertController(title: "Wrong VIN", message: "The VIN you have entered \((txt!.text!.uppercased())) doesn't match the VIN for the job \(self.job.vehicle!.vinNumber!)", preferredStyle: .alert)
                    
                    alert1.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                        action in
                        
                        
                        
                        alert1.dismiss(animated: true, completion: nil)
                        
                        
                    }))
                    
                    self.present(alert1, animated: true, completion: nil)
                    
                }
               
                
                
            }))
            
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                action in
                
                
                
                alert.dismiss(animated: true, completion: nil)
            }))
            
            DispatchQueue.main.async {
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        
    }
    
    func presentSkipAlert() {
        var txt : UITextField?
        
        let alert = UIAlertController(title: "", message: "Please specifiy the reason for skipping.", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {
            textfield in
            txt = textfield
            txt?.enablesReturnKeyAutomatically = false
            
        })
        
        alert.addAction(UIAlertAction(title: "Skip", style: .default, handler: {
            action in
            
            if txt!.text!.trimmingCharacters(in: .whitespaces).count > 0 {
                
                if self.pickup {
                    self.jobAppraisal.numberPlate!.pickup.entry = .skipped
                    self.jobAppraisal.numberPlate!.pickup.reasonForSkipping = txt!.text!
                    
                    self.jobAppraisal.status = .pickupAppraisalStarted
                    JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                    Requests.changeJobStatus(jobID: self.jobAppraisal.jobID!, status: .pickupAppraisalStarted)
                }
                else {
                    self.jobAppraisal.numberPlate!.dropoff.entry = .skipped
                    self.jobAppraisal.numberPlate!.dropoff.reasonForSkipping = txt!.text!
                    
                    self.jobAppraisal.status = .dropoffAppraisalStarted
                    JobsManager.saveJobAppraisal(job: self.jobAppraisal, saveExpenses: false)
                    Requests.changeJobStatus(jobID: self.jobAppraisal.jobID!, status: .dropoffAppraisalStarted)
                }
                
                
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()

                }
                
                alert.dismiss(animated: true, completion: nil)
            }
            else {
                let alert1 = UIAlertController(title: "No Reason", message: "You must enter a reason for skipping", preferredStyle: .alert)
                
                alert1.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                    action in
                    
                    
                    
                    alert1.dismiss(animated: true, completion: nil)
                    
                    
                }))
                
                self.present(alert1, animated: true, completion: nil)
            }
            
        }))
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            
           
            
            alert.dismiss(animated: true, completion: nil)
            
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func videoAppraisal(cell : UICollectionViewCell) {
        
        if cell.alpha < 1 {
            
            self.view.makeToast("Please complete previous steps first", duration: 1.5, position: .center)
            
            return
        }
        
        self.performSegue(withIdentifier: "to_video_appraisal", sender: nil)
    }
    
    func manualAppraisal(cell : UICollectionViewCell) {
        if cell.alpha < 1 {
            /*
            if job.appraisalToBeDoneOnExternalSystem != nil && job.appraisalToBeDoneOnExternalSystem == 1 {
                self.view.makeToast("Manual appraisal to be complete on external system", duration: 2.0, position: .center)
            }
            else if job.manualAppraisalRequired == 0 {
                self.view.makeToast("The company does not require a manual appraisal", duration: 2.0, position: .center)
            }
            else {
                self.view.makeToast("Please complete previous steps first", duration: 1.5, position: .center)
            }*/
            self.view.makeToast("Please complete previous steps first", duration: 1.5, position: .center)
            return
        }
        
        self.view.makeToastActivity(.center)
        
        DispatchQueue.main.async(execute: {
             self.performSegue(withIdentifier: "to_manual_appraisal", sender: nil)
        })
        
        
    }
    
    func petrolLevel(cell : UICollectionViewCell) {
        if cell.alpha < 1 {
            
            self.view.makeToast("Please complete previous steps first", duration: 1.5, position: .center)
            
            return
        }
        self.performSegue(withIdentifier: "to_petrol", sender: nil)
    }
    
    func mileage(cell : UICollectionViewCell) {
        if cell.alpha < 1 {
            
            self.view.makeToast("Please complete previous steps first", duration: 1.5, position: .center)
            
            return
        }
        self.performSegue(withIdentifier: "to_mileage", sender: nil)
    }
    
    func warningLights(cell : UICollectionViewCell) {
        if cell.alpha < 1 {
            
            self.view.makeToast("Please complete previous steps first", duration: 1.5, position: .center)
            
            return
        }
        self.performSegue(withIdentifier: "to_warning_lights", sender: nil)
    }
    func extras(cell : UICollectionViewCell) {
        if cell.alpha < 1 {
            
            self.view.makeToast("Please complete previous steps first", duration: 1.5, position: .center)
            
            return
        }
        self.performSegue(withIdentifier: "to_extras", sender: nil)
    }
    
    func paperwork(cell : UICollectionViewCell) {
        if cell.alpha < 1 {
            
            if job.fleetPaperworkRequired == nil || job.fleetPaperworkRequired == 0 {
                self.view.makeToast("Paperwork is not required", duration: 1.5, position: .center)
                
                return
            }
            self.view.makeToast("Please complete previous steps first", duration: 1.5, position: .center)
            
            return
        }
        self.performSegue(withIdentifier: "to_fleet", sender: nil)
    }
    
    func specialInstruction(cell : UICollectionViewCell) {
        if cell.alpha < 1 {
            if job.specialInstructions == nil || job.specialInstructions!.count == 0 {
                self.view.makeToast("No special instructions for this job", duration: 1.5, position: .center)
                
                return
            }
            self.view.makeToast("Please complete previous steps first", duration: 1.5, position: .center)
            
            return
        }
        self.performSegue(withIdentifier: "to_special_instructions", sender: nil)
    }
    
    func signature(cell : UICollectionViewCell) {
        if cell.alpha < 1 {
            
            self.view.makeToast("Please complete previous steps first", duration: 1.5, position: .center)
            
            return
        }
        self.performSegue(withIdentifier: "to_sign_off", sender: nil)
        
    }
    
    func startJob(cell : UICollectionViewCell) {
        if cell.alpha < 1 {
            
            self.view.makeToast("Please complete previous steps first", duration: 1.5, position: .center)
            
            return
        }
        self.view.isUserInteractionEnabled = false
        self.view.makeToastActivity(.center)
        
        
        self.perform(#selector(delayPODS), with: nil, afterDelay: 0.2)
        
 
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "to_video_appraisal" {
            let vc = segue.destination as! VideoAppraisalViewController
            vc.pickup = pickup
        }
        else if segue.identifier == "to_manual_appraisal" {
            let vc = segue.destination as! VehicalAssessmentViewController
            vc.pickup = pickup
        }
        else if segue.identifier == "to_scanner" {
            let vc = segue.destination as! ScannerViewController
            vc.pickup = pickup
        }
        else if segue.identifier == "to_mileage" {
            let vc = segue.destination as! MileageViewController
            vc.pickup = pickup
        }
        else if segue.identifier == "to_petrol" {
            let vc = segue.destination as! PetrolViewController
            vc.pickup = pickup
        }
        else if segue.identifier == "to_warning_lights" {
            let vc = segue.destination as! WarningLightsViewController
            vc.pickup = pickup
        }
        else if segue.identifier == "to_extras" {
            let vc = segue.destination as! ExtrasViewController
            vc.pickup = pickup
        }
        else if segue.identifier == "to_sign_off" {
            let vc = segue.destination as! SignOffViewController
            vc.pickup = pickup
        }else if segue.identifier == "to_start_job" {
            if let vc = segue.destination as? MapProgressViewController{
                vc.isDefaulShowSpecialInstruction = true
            }
            
        }
       
    }
    func copyPickUpImagesToDropOff(){
        let pickUpAppraisalPath = OfflineFolderStructure.getAppraisalImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobAppraisal.jobID!, pickup: true)
        let dropOffAppraisalPath = OfflineFolderStructure.getAppraisalImagesPath(driverID: AppManager.sharedInstance.currentUser!.driverID!, jobID: jobAppraisal.jobID!, pickup: false)
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: URL(string:pickUpAppraisalPath)!, includingPropertiesForKeys: nil)

            for filename in urls {
                let data = try Data(contentsOf: filename)
                let dropOff = "\(dropOffAppraisalPath)/\(filename.lastPathComponent)"
                try data.write(to: URL(string:dropOff)!, options: .atomicWrite)
            }
        }
        catch let error {
           print(error.localizedDescription)
            let exception = NSException(name:NSExceptionName(rawValue: "copyPickUpImagesToDropOff"),
                                        reason:"\(error.localizedDescription)",
                userInfo:nil)
            Bugsnag.notify(exception)
        }
    }
    @objc func delayPODS() {
        JobsManager.generatePODSFile(job: jobAppraisal, completion: {
            (url, error) in
            
            DispatchQueue.main.async {
                self.view.hideToastActivity()
                self.view.isUserInteractionEnabled = true
            }
            
            
            if url != nil {
                
                do {
                    let data = try Data(contentsOf: url!)
                    
                    //duplicate images from pick up to drpo off
                    self.copyPickUpImagesToDropOff()
                    
                    jobAppraisal.copyPickUpToDropOff()
                    
                    jobAppraisal.status = .driving
                    
                    JobsManager.saveJobAppraisal(job: jobAppraisal, saveExpenses: false)
                    
                    Requests.changeJobStatus(jobID: jobAppraisal.jobID!, status: JobStatus.driving)
                    Requests.pushAppraisalWithCompletion(jobID: jobAppraisal.jobID!, appraisal: data, completion: { (success) in
                        //Requests.pushAppraisal(jobID: jobAppraisal.jobID!, appraisal: data)
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "to_start_job", sender: nil)
                        }
                    })
                }
                catch {
                    let exception = NSException(name:NSExceptionName(rawValue: "delayPODS"),
                                                reason:"\(error.localizedDescription)",
                        userInfo:nil)
                    Bugsnag.notify(exception)
                }
                
                
                
            }
            else {
                var message = "An unknown error occurred"
                
                if error != nil {
                    message = "An error occurred: \(error!.localizedDescription)"
                }
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            
            
        })
    }
    
}
