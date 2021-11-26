//
//  AllMessagesViewController.swift
//  G4VL
//
//  Created by Michael Miller on 16/05/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit
import Bugsnag

class AllMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var refreshing = false
    
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        
        refreshControl.tintColor = UIColor.black
        
        return refreshControl
    }()
    
    var jobsWithMessages : JobsWithMessages?
    @IBOutlet var table : UITableView!
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        
        tableSetup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
        
    }
    
    func tableSetup() {
        table.addSubview(self.refreshControl)
        table.estimatedRowHeight = UITableView.automaticDimension
        table.estimatedSectionHeaderHeight = UITableView.automaticDimension
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadData()
    }
    
    
    func loadData() {
        if !refreshing {
            refreshing = true
            
            if !refreshControl.isRefreshing {
                self.view.makeToastActivity(.center)
            }
            
            Requests.getMessages(driverID: AppManager.sharedInstance.currentUser!.driverID) { (response) in
                if response.errorMessage == nil && response.data != nil {
                    DispatchQueue.main.async {
                        if let data = response.data {
                            do {
                                self.jobsWithMessages = try JSONDecoder().decode(JobsWithMessages.self, from: data)
                                self.loadingFinishedWithSuccess()
                            }
                            catch {
                                let exception = NSException(name:NSExceptionName(rawValue: "loadData"),
                                                            reason:"\(error.localizedDescription)",
                                    userInfo:nil)
                                Bugsnag.notify(exception)
                                self.loadingFinishedWithSuccess(false)
                                
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    func loadingFinishedWithSuccess(_ success : Bool = true) {
        
        refreshing = false
        refreshControl.endRefreshing()
        self.view.hideToastActivity()
        table.reloadData()
        
        if !success {
            self.view.makeToast("An error occurred, pull down to try again")
        }
    }
    
    
    //MARK: UItableView Delegate/Datasource
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return jobsWithMessages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobsWithMessages![section].messages.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let job = jobsWithMessages![section]
        
        return "(Job \(job.jobID)) \(job.journeyDescription)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if(cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        }
        
        let message = jobsWithMessages![indexPath.section].messages[indexPath.row]
        
        cell!.textLabel?.text = message.messageContent ?? ""
        cell!.textLabel?.numberOfLines = 0
        cell!.detailTextLabel?.text = message.sentToDriverAt
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell?.detailTextLabel?.textColor = UIColor.lightGray
        return cell!;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let message = jobsWithMessages![indexPath.section].messages[indexPath.row]
//        self.performSegue(withIdentifier: "to_message", sender: message)
    }
    
    //MARK: Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to_message" {
            
            let message = sender as! Message;
            
            let vc : ReadMessageViewController = segue.destination as! ReadMessageViewController
            vc.message = message
            
            
        }
    }
    
}

