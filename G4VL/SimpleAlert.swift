//
//  SimpleDismissAlert.swift
//  G4VL
//
//  Created by Foamy iMac7 on 07/09/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import Foundation

class SimpleAlert {
    
    static func dismissAlert(message:String?, title:String?, cancel:String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: {
            action in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        return alert
    }

    
}
