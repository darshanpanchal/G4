//
//  Address.swift
//  G4VL
//
//  Created by Michael Miller on 17/03/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation

class Address: Codable {
    let id: Int?
    let createdAt, updatedAt, postcode: String?
    let houseNumberOrName: String?
    let addressLine1: String?
    let addressLine2, addressLine3: String?
    let townCity, countyArea: String?
    let country: String?
    let latt, long: String?
    let contactNumber:String?
    let openingTime:String?
    let compoundOpeningTime:String?
    let contactName:String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case postcode
        case houseNumberOrName = "house_number_or_name"
        case addressLine1 = "address_line_1"
        case addressLine2 = "address_line_2"
        case addressLine3 = "address_line_3"
        case townCity = "town_city"
        case countyArea = "county_area"
        case country, latt, long
        case contactNumber = "contact_telephone_number"
        case openingTime = "opening_times"
        case compoundOpeningTime = "compound_opening_times"
        case contactName = "contact_name"
    }
    
    init(id: Int?, createdAt: String?, updatedAt: String?, postcode: String?, houseNumberOrName: String?, addressLine1: String?, addressLine2: String?, addressLine3: String?, townCity: String?, countyArea: String?, country: String?, latt: String?, long: String?,contactNumber:String?,openingTime:String?,compoundOpeningTime:String?,contactName:String?) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.postcode = postcode
        self.houseNumberOrName = houseNumberOrName
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressLine3 = addressLine3
        self.townCity = townCity
        self.countyArea = countyArea
        self.country = country
        self.latt = latt
        self.long = long
        self.contactNumber = contactNumber
        self.openingTime = openingTime
        self.compoundOpeningTime = compoundOpeningTime
        self.contactName = contactName
    }
}
