//
//  ReadMessageViewController.swift
//  G4VL
//
//  Created by Foamy iMac7 on 18/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

class ReadMessageViewController: UIViewController {
    
    var message : Message?
    @IBOutlet var messageTextView : UITextView!
    @IBOutlet var dateLabel : UILabel!
    @IBOutlet var fromLabel : UILabel!
    
    @IBAction func back() {
        self.navigationController!.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        messageTextView.text = message!.messageContent ?? ""
        dateLabel.text = message!.sentToDriverAt ?? "unknown"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
