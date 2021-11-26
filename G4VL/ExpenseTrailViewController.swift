//
//  ExpenseTrailViewController.swift
//  G4VL
//
//  Created by user on 05/11/19.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import UIKit

class ExpenseTrailViewController: UIViewController {

    var currentDate = Date()
    var dateFormate = DateFormatter()
    
    @IBOutlet var lblWeekDetail:UILabel!
    var arrayOfExpense:[[String:Any]] = []
    @IBOutlet var tableViewExpense:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configureTableView()
        
        dateFormate.dateFormat = "dd-MM-YYYY"
        
        self.configureTableView()

        self.getExpenseTrail(strDates: self.getCurrentWeekDate())
        
    }
    // MARK: - Custom methods
    func configureTableView(){
        let objNIb = UINib.init(nibName: "ExpenseTrailTableViewCell", bundle: nil)
        self.tableViewExpense.register(objNIb, forCellReuseIdentifier: "ExpenseTrailTableViewCell")
        self.tableViewExpense.delegate = self
        self.tableViewExpense.dataSource = self
        self.tableViewExpense.reloadData()
        self.tableViewExpense.tableHeaderView = UIView()
        self.tableViewExpense.tableFooterView = UIView()
    }
    func getCurrentWeekDate()->[String]{
        var dates : [String] = []
        if let endDate = Calendar.current.date(byAdding: .day, value: -6, to: self.currentDate){
          
            let strEndDate = self.dateFormate.string(from: endDate)
            dates.append(strEndDate)
            let strStartDate = self.dateFormate.string(from: self.currentDate)
            dates.append(strStartDate)
            return dates
        }
        
        return []
    }
    func getPreviousWeekDate(fromDate:Date)->[String]{
        var dates : [String] = []
        
        if let startDate = Calendar.current.date(byAdding: .day, value: -6, to: self.currentDate){
            let strStartDate = self.dateFormate.string(from: startDate)
            dates.append(strStartDate)
            let strEndDate = self.dateFormate.string(from: self.currentDate)
            dates.append(strEndDate)
            
            return dates
        }
        return []
    }
    func getNextWeekDate(fromDate:Date)->[String]{
        var dates : [String] = []
        
        if let endDate = Calendar.current.date(byAdding: .day, value: 6, to: self.currentDate){
            let strStartDate = self.dateFormate.string(from: self.currentDate)
            dates.append(strStartDate)
            let strEndDate = self.dateFormate.string(from: endDate)
            dates.append(strEndDate)
            self.currentDate = endDate
            return dates
        }
        return []
    }
    // MARK: - Selector Methods
    @IBAction func nextWeekSelector(sender:UIButton){
        print(self.currentDate)
        DispatchQueue.main.async {
            if let update = Calendar.current.date(byAdding: .day, value: 1, to: self.currentDate){
                self.currentDate = update
            }
            let nextDates = self.getNextWeekDate(fromDate: self.currentDate)
            self.getExpenseTrail(strDates: nextDates)
        }
        
    }
    @IBAction func previosWeekSelector(sender:UIButton){
        DispatchQueue.main.async {
//            if let update = Calendar.current.date(byAdding: .day, value: -1, to: self.currentDate){
//                self.currentDate = update
//            }
            if let startDate = Calendar.current.date(byAdding: .day, value: -7, to: self.currentDate){
                self.currentDate = startDate
            }
            let previousDates = self.getPreviousWeekDate(fromDate: self.currentDate)
            self.getExpenseTrail(strDates: previousDates)
        }
        
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - API methods
    func getExpenseTrail(strDates:[String]){
        if strDates.count == 2{
            self.lblWeekDetail.text = "\(strDates.first ?? "") To \(strDates.last ?? "")"
        }
        self.view.isUserInteractionEnabled = false
        self.view.makeToastActivity(.center)
        Requests.getAllJobsExpenseTrail(startDate: strDates.first!, endDate: strDates.last!) { (result) in
            DispatchQueue.main.async {
                
                self.view.isUserInteractionEnabled = true
                self.view.hideToastActivity()
              
                if let code = result.statusCode,code == 200{
                    if let objData = result.data{
                        do{
                            if let json = try JSONSerialization.jsonObject(with: objData, options: .allowFragments) as? [[String:Any]]{
                                self.arrayOfExpense.removeAll()
                                if json.count > 0{
                                    for objJSON:[String:Any] in json{
                                        self.arrayOfExpense.append(objJSON)
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.tableViewExpense.reloadData()
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.arrayOfExpense.removeAll()
                                    self.tableViewExpense.reloadData()
                                }
                            }
                        }catch{
                            print("====== \(error.localizedDescription)")
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.arrayOfExpense.removeAll()
                            self.tableViewExpense.reloadData()
                        }
                    }
                }
            }
            
        }
        
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
extension ExpenseTrailViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objCell = tableView.dequeueReusableCell(withIdentifier: "ExpenseTrailTableViewCell") as! ExpenseTrailTableViewCell
        if self.arrayOfExpense.count > indexPath.row{
            let objJON = self.arrayOfExpense[indexPath.row]
            if let objtime = objJON["time"]{
                objCell.lbltime.text = "\(objtime)"
            }
            if let objtime = objJON["refrenece"]{
                objCell.lblrefrenece.text = "\(objtime)"
            }
            if let objtime = objJON["type"]{
                objCell.lbltype.text = "\(objtime)"
            }
            if let objtime = objJON["from"]{
                objCell.lblfrom.text = "\(objtime)"
            }
            if let objtime = objJON["balance"]{
                objCell.lblbalance.text = "\(objtime)"
            }
            if let objtime = objJON["actioned_by"]{
                objCell.lblactioned_by.text = "\(objtime)"
            }
            if let objtime = objJON["associated_job"]{
                objCell.lblassociated_job.text = "JOB #\(objtime)"
            }
        }
        return objCell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableViewExpense.isHidden = !(self.arrayOfExpense.count > 0)
        return self.arrayOfExpense.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400.0
    }
}
