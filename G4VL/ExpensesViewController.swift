//
//  ExpensesViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 28/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class ExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var loaded = false
    @IBOutlet var theTable : UITableView!
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loaded {
            //no point running this first time
            theTable.reloadData()
        }
        loaded = true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func addExpense() {
        self.performSegue(withIdentifier: "to_add_expense", sender: nil)
    }
    
    //MARK: TableView Delegate/Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return AppManager.sharedInstance.currentJobAppraisal!.expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let expense = AppManager.sharedInstance.currentJobAppraisal!.expenses[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ExpenseCell
        
        cell.lblCost.text = expense.getReadableCost(withSign: true)
        cell.lblDescription.text = expense.itemDescription
       
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let expense = AppManager.sharedInstance.currentJobAppraisal!.expenses[indexPath.row]
        
        self.performSegue(withIdentifier: "to_add_expense", sender: expense)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "to_add_expense"
        {
            if sender != nil {
                let vc = segue.destination as! AddExpenseViewController
                vc.expense = sender as? Expense
            }
        }
    }

}
