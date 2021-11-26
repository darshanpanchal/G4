//
//  MessagePopupViewController.swift
//  G4VL
//
//  Created by Michael Miller on 13/12/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit
import QuickLook

protocol MessagePopupDelegate {
    func finishedCheckingMessages()
    func finishedCheckingDriverWages()
}

enum PopupMode {
    case driverMessages, wages
}

class MessagePopupViewController: UIViewController {
    
    var delegate : MessagePopupDelegate?
    var loaded = false
    var jobWithUnreadMessages : JobsWithMessages?
    var wages : Wages?
    var mode : PopupMode = .driverMessages
    var actionToEnable : UIAlertAction?
   var previewItem:NSURL?

    var downloadableURL:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !loaded {
            loaded = true
            
            UIView.animate(withDuration: 0.2, animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            }) { (finished) in
                switch self.mode {
                case .driverMessages:
                    self.showMessage()
                case .wages:
                    self.showWages()
                }
                
            }
        }
    }
    
    func showMessage() {
        
        
        guard jobWithUnreadMessages!.count != 0,
            let jobWithUnreadMessage = jobWithUnreadMessages!.first,
            jobWithUnreadMessage.messages.count != 0,
            let message = jobWithUnreadMessage.messages.first
            else {
                self.delegate?.finishedCheckingMessages()
                self.dismiss(animated: false, completion: nil)
                return
        }
        guard let _ = AppManager.sharedInstance.currentUser else {
            return
        }
        let result = UploadManager.shared.getFailedRequests().filter{
            return $0.driverID == AppManager.sharedInstance.currentUser!.driverID
                && $0.jobID == message.jobID
                && $0.messageID == message.id
        }
        
        if result.count > 0 {
            //there is a failed request in the queue for this message id so skip this for now
            self.jobWithUnreadMessages!.first?.messages.remove(at: 0)
            if self.jobWithUnreadMessages!.first?.messages.count == 0 {
                self.jobWithUnreadMessages!.remove(at: 0)
            }
            self.showMessage()
            
            return
        }
        
        self.view.isUserInteractionEnabled = true
        self.view.hideToastActivity()
        
        
        let alert = UIAlertController(title: "New message for Job \(message.jobID ?? 0)", message: "\(jobWithUnreadMessage.journeyDescription.uppercased())\n\n\(message.messageContent ?? "")", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            
            Requests.markAsRead(driverID: AppManager.sharedInstance.currentUser!.driverID, jobID: message.jobID!, messageID: message.id!)
            
            self.jobWithUnreadMessages!.first?.messages.remove(at: 0)
            if self.jobWithUnreadMessages!.first?.messages.count == 0 {
                self.jobWithUnreadMessages!.remove(at: 0)
            }
            self.showMessage()
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    func showWages() {
    
        guard wages != nil && wages!.count != 0, let wage = wages!.first, wage.showToDriver != nil, wage.showToDriver == 1 else {
            self.delegate?.finishedCheckingDriverWages()
            self.dismiss(animated: false, completion: nil)
            return
        }
        
        let result = UploadManager.shared.getFailedRequests().filter{
            return $0.driverID == AppManager.sharedInstance.currentUser!.driverID
                && $0.wageID == wage.id
        }
        
        if result.count > 0 {
            //there is a failed request in the queue for this wage id so skip this for now
            self.wages!.remove(at: 0)
            self.showWages()
            return
        }
        
        
        self.view.isUserInteractionEnabled = true
        self.view.hideToastActivity()
        
        
        let alert = UIAlertController(title: "TSI Approval", message:"Please approve/unapprove your TSI for the \(getWagePeriodString(wage)).\n\nTSI: \(formatWage(wage))\n\nIf you unapprove, you MUST add a reason. \n\nBy clicking submit, you are agreeing and electronically signing that this payment and the amounts on the form are correct and accepted.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "TSI BREAKDOWN", style: .default, handler: { (action) in
            
            self.showWageBreakDown(wage)
            alert.dismiss(animated: false, completion: nil)
            
        }))
        
        alert.addTextField { textField in
            textField.placeholder = "Please enter reason here"//"Enter a reason (if applicable)"
            textField.addTarget(self, action: #selector(self.textChanged(sender:)), for: .editingChanged)
        }
        let action = UIAlertAction(title: "UNAPPROVE", style: .destructive, handler: { (action) in
                  
                  let textField = alert.textFields!.first!
                  Requests.actionOnWage(driverID: AppManager.sharedInstance.currentUser!.driverID, wageID: wage.id!, approve: false, reason: textField.text ?? "")
                  self.wages?.remove(at: 0)
                  self.showWages()
              })
        alert.addAction(UIAlertAction(title: "APPROVE", style: .default, handler: { (action) in
            
            let textField = alert.textFields!.first!
            Requests.actionOnWage(driverID: AppManager.sharedInstance.currentUser!.driverID, wageID: wage.id!, approve: true, reason: textField.text ?? "")
            self.wages?.remove(at: 0)
            self.showWages()
        }))
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action) in
               alert.dismiss(animated: false, completion: nil)
              self.dismiss(animated: false, completion: nil)
        }))
      
        
        action.isEnabled = false
        actionToEnable = action
        
        alert.addAction(action)
        
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showWageBreakDown(_ wage : Wage) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        
        let message:NSMutableAttributedString = NSMutableAttributedString()
        
        if wage.breakdown != nil && wage.breakdown!.count > 0 {
            paragraphStyle.alignment = NSTextAlignment.left
            for item in wage.breakdown! {
                message.append("\nDate: \(item.date ?? "")\n".getNormalString())
                message.append("Type: \(item.type ?? "")\n".getNormalString())
                message.append("Description: \(item.description ?? "")\n".getNormalString())
                message.append("Category: \(item.category ?? "")\n".getNormalString())
                message.append("Company: ".getNormalString())
                message.append("\(item.company ?? "")\n".getBoldString())
                message.append("Amount: ".getNormalString())
                message.append("£\(item.formattedCurrencyString ?? "")\n".getDebitCreditString(category: item.category ?? ""))
            }
            message.append("\n".getNormalString())
           message.append("ACV Total : £\(wage.acvTotal ?? "0.00")\n".getBoldString())
           message.append("BVL Total : £\(wage.bvlTotal ?? "0.00")\n".getBoldString())
           message.append("G4 Total  : £\(wage.g4Total ?? "0.00")\n".getBoldString())
           message.append("CND Total : £\(wage.cndTotal ?? "0.00")\n".getBoldString())
           message.append("SCCD Total : £\(wage.sccdTotal ?? "0.00")\n\n\n".getBoldString())
            
           message.append("Total Amount Payable : \(self.formatWage(wage))".getBoldString())
            
        }
        else {
            paragraphStyle.alignment = NSTextAlignment.center
            message.append("no items exist in breakdown".getNormalString())
        }
        /*
        let messageText = NSMutableAttributedString(
            string: message,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor : UIColor.black
            ]
        )*/
        
        
        let alert = UIAlertController(title: "TSI Breakdown for the \(getWagePeriodString(wage))", message:"", preferredStyle: .alert)
        
        alert.setValue(message, forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { (action) in
            
            self.showWages()
            
            
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
            //Save PDF to device
            self.getWagesDownloadURL(wagesId: wage.id ?? 0)
            //self.savePDFFileToPdfFileToDevice(wagesId: wage.id ?? 0)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    func getWagesDownloadURL(wagesId:Int){
        guard downloadableURL.count == 0 else {
            DispatchQueue.main.async {
                self.savePDFFileToPdfFileToDevice()
            }
            return
        }
        //https://staging.portal.g4vehiclelogistics.co.uk/api/v1/driver-app/get-wages-download-url/{wageId}
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = false
            self.view.makeToastActivity(.center)
        }
        Requests.getWagesDownloadURL(wagesID: "\(wagesId)") { (result) in
            DispatchQueue.main.async {
                 self.view.isUserInteractionEnabled = true
                 self.view.hideToastActivity()
                if let code = result.statusCode,code == 200{
                     if let objData = result.data{
                         do{
                             if let json = try JSONSerialization.jsonObject(with: objData, options: .allowFragments) as? [String:Any]{
                                print(json)
                                if let url = json["url"] as? String{
                                    self.downloadableURL = url
                                    DispatchQueue.main.async {
                                        self.savePDFFileToPdfFileToDevice()
                                    }
                                }
                             }else{
                                 DispatchQueue.main.async {
                                     
                                 }
                             }
                         }catch{
                             print("====== \(error.localizedDescription)")
                         }
                     }else{
                        
                     }
                 }
            }
        }
        
    }
    func savePDFFileToPdfFileToDevice(){
        guard self.downloadableURL.count > 0 else {
            return
        }
        let urlString = downloadableURL
        /*
        let urlString = "https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2018-financial-year-provisional/Download-data/annual-enterprise-survey-2018-financial-year-provisional-size-bands-csv.csv"*/
        let url = URL(string: urlString)
        let fileName = String((url!.lastPathComponent)) as NSString
        // Create destination URL
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
        guard !FileManager.default.fileExists(atPath: destinationFileUrl.path) else {
            DispatchQueue.main.async {
                self.showdownloadedFile(path: destinationFileUrl.path)
            }
            return
        }

        //Create URL to the source file you want to download
        let fileURL = URL(string: urlString)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url:fileURL!)
        
        DispatchQueue.main.async {
           self.view.isUserInteractionEnabled = false
           self.view.makeToastActivity(.center)
        }
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
           
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                    DispatchQueue.main.async {
//                        self.view.makeToast("Successfully downloaded \(fileName)", point: CGPoint.init(x: self.view.center.x, y: 120), title: nil, image: nil, completion: nil)
//                    }
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    DispatchQueue.main.async {
                      self.view.isUserInteractionEnabled = true
                      self.view.hideToastActivity()
                      if FileManager.default.fileExists(atPath: destinationFileUrl.path){
                        self.showdownloadedFile(path: destinationFileUrl.path)
                      }else{
                        self.showWages()
                        }
                    }
                } catch (let writeError) {
                    DispatchQueue.main.async {
                           self.view.isUserInteractionEnabled = true
                           self.view.hideToastActivity()
                           if FileManager.default.fileExists(atPath: destinationFileUrl.path){
                             self.showdownloadedFile(path: destinationFileUrl.path)
                           }else{
                            self.showWages()
                            }
                   }
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
            } else {
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.view.hideToastActivity()
                   if FileManager.default.fileExists(atPath: destinationFileUrl.path){
                      self.showdownloadedFile(path: destinationFileUrl.path)
                   }else{
                    self.showWages()
                    }
                }
                print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "")")
            }
        }
        task.resume()
    }
    
    func showdownloadedFile(path:String){
        DispatchQueue.main.async {
            self.previewItem = URL.init(fileURLWithPath: path) as NSURL
                       let previewController = QLPreviewController()
                       previewController.dataSource = self
                       previewController.delegate = self
                       previewController.currentPreviewItemIndex = 0
                       self.present(previewController, animated: true, completion:nil)
        }
    }
    
    
    
    @objc func textChanged(sender:UITextField) {
        self.actionToEnable?.isEnabled = (sender.text!.count > 0)
    }
    
    func formatWage(_ wage:Wage) -> String {
        
        guard  let pence = wage.wageTotalPayableInPence else {
            return "£0"
        }
        
        let pennies = pence % 100
        
        if pennies < 10 {
            return "£\(pence/100).0\(pennies)"
        }
        
        return "£\(pence/100).\(pennies)"
    }
    
    func getWagePeriodString(_ wage:Wage)-> String {
        
        var weekString = ""
        switch wage.calendarWeek! {
        case 1:
            weekString = "1st week"
        case 2:
            weekString = "2nd week"
        case 3:
            weekString = "3rd week"
        case 4:
            weekString = "4th week"
        default:
            weekString = "5th week"
        }
        
        var monthString = ""
        switch wage.calendarMonth! {
        case 1:
            monthString = "January"
        case 2:
            monthString = "February"
        case 3:
            monthString = "March"
        case 4:
            monthString = "April"
        case 5:
            monthString = "May"
        case 6:
            monthString = "June"
        case 7:
            monthString = "July"
        case 8:
            monthString = "August"
        case 9:
            monthString = "September"
        case 10:
            monthString = "October"
        case 11:
            monthString = "November"
        default:
            monthString = "December"
        }
        
        
        return "\(weekString) of \(monthString) \(wage.calendarYear!)"
        
    }

}
extension String{
    func getNormalString()->NSAttributedString{
            let paragraphStyle = NSMutableParagraphStyle()
           paragraphStyle.alignment = NSTextAlignment.left
        let objString = NSAttributedString.init(string: self, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
            NSAttributedString.Key.foregroundColor : UIColor.black
        ])
        return objString
    }
    func getBoldString()->NSAttributedString{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let objString = NSAttributedString.init(string: self, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15.0),
            NSAttributedString.Key.foregroundColor : UIColor.black,
            
        ])
        return objString
    }
    func getDebitCreditString(category:String)->NSAttributedString{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        if category == "credit"{
            let objString = NSAttributedString.init(string: self, attributes: [
                       NSAttributedString.Key.paragraphStyle: paragraphStyle,
                       NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                       NSAttributedString.Key.foregroundColor : UIColor.green
                   ])
                   return objString
        }else if category == "debit"{
            let objString = NSAttributedString.init(string: self, attributes: [
                       NSAttributedString.Key.paragraphStyle: paragraphStyle,
                       NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                       NSAttributedString.Key.foregroundColor : UIColor.red
                   ])
                   return objString
        }else{
            let objString = NSAttributedString.init(string: self, attributes: [
                       NSAttributedString.Key.paragraphStyle: paragraphStyle,
                       NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                       NSAttributedString.Key.foregroundColor : UIColor.black
                   ])
                   return objString
        }
        
       
    }
}
extension MessagePopupViewController:QLPreviewControllerDataSource,QLPreviewControllerDelegate{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        if let _ = previewItem{
            return self.previewItem!
        }else{
            return URL.init(fileURLWithPath:"") as QLPreviewItem
        }
        
    }
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        DispatchQueue.main.async {
            self.showWages()
        }
    }
    
}
