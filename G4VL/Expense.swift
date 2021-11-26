//
//  Expenses.swift
//  G4VL
//
//  Created by Michael Miller on 21/03/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit


class Expense : Equatable,Codable {
    private var cost : Int
    var itemDescription : String?
    var photoReceiptName : String?
    var label = "Expenses"
    var isJetWash = false
    var uploadCarephotoReceiptName:String?
    
    enum CodingKeys: String, CodingKey {
        case cost = "cost_in_pence"
        case itemDescription = "description"
        case photoReceiptName = "photo_name"
        case label
        case isJetWash = "is_jet_wash"
        case uploadCarephotoReceiptName = "uploadcare_image_url"
    }
    
    init(cost : Int?,itemDescription : String?,photoReceiptName : String?, isJetWash : Bool?,uploadCarephotoReceiptName:String? = nil) {
        self.cost = cost ?? 0
        self.itemDescription = itemDescription
        self.photoReceiptName = photoReceiptName
        self.uploadCarephotoReceiptName = uploadCarephotoReceiptName
    }
    
    func setIsJetWash(_ value:Bool) {
        isJetWash = value
        
        if isJetWash {
            itemDescription = "Jet Wash"
        }
    }
    
    
    func getCostInPennies()->Int {
        return cost
    }
    
    func setCost(string:String) {
        //convert string to pennies i.e 1.54 -> 154
        var costFloat = Double(string)!
        costFloat = costFloat * 100
        self.cost = Int(costFloat)
    }
    
    func setCostFromPennies(pennies:Int) {
        self.cost = pennies
    }
    
    func getReadableCost(withSign:Bool) -> String {
        if withSign {
            return String(format: "£%.2f", Double(cost)/100)
        }
        return String(format: "%.2f", Double(cost)/100)
    }
    
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        return lhs.cost == rhs.cost && lhs.itemDescription == rhs.itemDescription && lhs.photoReceiptName == rhs.photoReceiptName
    }
}
class ExpensesTrailDetail:NSObject,Codable{
    var time:String?
    var refrenece:String?
    var type:String?
    var from:String
    var balance:String?
    var actioned_by:String?
    var associated_job:String?
    
    enum CodingKeys: String, CodingKey {
        case time
        case refrenece
        case type
        case from
        case balance
        case actioned_by
        case associated_job
    }
    init(time:String,refrenece:String,type:String,from:String,balance:String,actioned_by:String,associated_job:String){
        self.time = time
        self.refrenece = refrenece
        self.type = type
        self.from = from
        self.balance = balance
        self.actioned_by = actioned_by
        self.associated_job = associated_job
    }
}

