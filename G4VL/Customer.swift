//
//  Customer.swift
//  G4VL
//
//  Created by Michael Miller on 17/03/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation



class Customer: Codable {
    let id: Int?
    let name: String?
    let companyId: Int?
    let telephone1, telephone2: String?
    let contactName, contactEmail, contactTelephone1, contactTelephone2: String?
    let disclaimer:String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case companyId = "company_id"
        case telephone1 = "telephone_1"
        case telephone2 = "telephone_2"
        case contactName = "contact_name"
        case contactEmail = "contact_email"
        case contactTelephone1 = "contact_telephone_1"
        case contactTelephone2 = "contact_telephone_2"
        case disclaimer
    }
    
    init(id: Int?, customerAddedById: Int?, name: String?, mainAddressId: Int?, invoiceAddressId: Int?, companyId: Int?, telephone1: String?, telephone2: String?, contactName: String?, contactEmail: String?, contactTelephone1: String?, contactTelephone2: String?,disclaimer:String?) {
        self.id = id
        self.name = name
        self.companyId = companyId
        self.telephone1 = telephone1
        self.telephone2 = telephone2
        self.contactName = contactName
        self.contactEmail = contactEmail
        self.contactTelephone1 = contactTelephone1
        self.contactTelephone2 = contactTelephone2
        self.disclaimer = disclaimer
    }
}
