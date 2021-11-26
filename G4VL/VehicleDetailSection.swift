//
//  VehicalDetailSection.swift
//  G4VL
//
//  Created by Foamy iMac7 on 24/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit

typealias VehicleDetailSections = [VehicleDetailSection]

class VehicleDetailSection: Codable {
    let label: String?
    let vehicleDetailRows: [VehicleDetailRow]?
    
    enum CodingKeys: String, CodingKey {
        case label
        case vehicleDetailRows = "vehicle_detail_rows"
    }
    
    init(label: String?, vehicleDetailRows: [VehicleDetailRow]?) {
        self.label = label
        self.vehicleDetailRows = vehicleDetailRows
    }
}
