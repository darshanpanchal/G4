// To parse the JSON, add this file to your project and do:
//
//   let wages = try? newJSONDecoder().decode(Wages.self, from: jsonData)

import Foundation

typealias Wages = [Wage]

class Wage: Codable {
    let id, driverId: Int?
    let calendarWeek, calendarMonth, calendarYear: Int?
    let breakdown: [Breakdown]?
    let driverApproved: Int?
    let wageTotalPayableInPence: Int?
    let driverNotApprovedReason: String?
    let driverApprovedReason: String?
    let showToDriver: Int?
    let acvTotal, bvlTotal, g4Total, cndTotal, sccdTotal:String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case driverId = "driver_id"
        case calendarWeek = "calendar_week"
        case calendarMonth = "calendar_month"
        case calendarYear = "calendar_year"
        case breakdown
        case driverApproved = "driver_approved"
        case wageTotalPayableInPence = "wage_total_payable_in_pence"
        case driverNotApprovedReason = "driver_not_approved_reason"
        case driverApprovedReason = "driver_approved_reason"
        case showToDriver = "show_to_driver"
        case acvTotal = "breakdown_acv_total"
        case bvlTotal = "breakdown_bvl_total"
        case g4Total = "breakdown_g4_total"
        case cndTotal = "breakdown_cnd_total"
        case sccdTotal = "breakdown_sccd_total"
    }
    
    init(id: Int?, driverId: Int?, calendarWeek: Int?, calendarMonth: Int?, calendarYear: Int?, breakdown: [Breakdown]?, driverApproved: Int?, wageTotalPayableInPence: Int?, driverNotApprovedReason: String?, driverApprovedReason: String?, showToDriver: Int?,acvTotal:String?,bvlTotal:String?,g4Total:String?,cndTotal:String?,sccdTotal:String?) {
        self.id = id
        self.driverId = driverId
        self.calendarWeek = calendarWeek
        self.calendarMonth = calendarMonth
        self.calendarYear = calendarYear
        self.breakdown = breakdown
        self.driverApproved = driverApproved
        self.wageTotalPayableInPence = wageTotalPayableInPence
        self.driverNotApprovedReason = driverNotApprovedReason
        self.driverApprovedReason = driverApprovedReason
        self.showToDriver = showToDriver
        self.acvTotal = acvTotal
        self.bvlTotal = bvlTotal
        self.g4Total = g4Total
        self.cndTotal = cndTotal
        self.sccdTotal = sccdTotal
        
        
    }
    
    class Breakdown: Codable {
        let date, type, category, description: String?
        let formattedCurrencyString: String?
        let company:String?
        enum CodingKeys: String, CodingKey {
            case date, type, category, description, company
            case formattedCurrencyString = "formatted_currency_string"
        }
        
        init(date: String?, type: String?, category: String?, description: String?, formattedCurrencyString: String?,company:String?) {
            self.date = date
            self.type = type
            self.category = category
            self.description = description
            self.formattedCurrencyString = formattedCurrencyString
            self.company = company
        }
    }
}




