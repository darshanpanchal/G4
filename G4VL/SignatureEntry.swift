//
//  SignatureEntry.swift
//  G4VL
//
//  Created by Michael Miller on 15/02/2019.
//  Copyright © 2019 Foamy iMac7. All rights reserved.
//

import Foundation


class SignatureEntry : NSObject,Codable {
    var label : String?
    var signatureFileName : String?
    var signedBy : String?
    var dateSigned : String?
    var uploadcareImageUrl:String?
    var welldress:DriverQuestion?
    var driverexperience:DriverQuestion?
    var driverbehaviour:DriverQuestion?
    var model:SignatureConfirmation?
    var telepod:SignatureConfirmation?
    var otherpaperwork:SignatureConfirmation?
    
    enum CodingKeys: String, CodingKey  {
        case label
        case welldress
        case driverexperience
        case driverbehaviour
        case signatureFileName = "signature_image"
        case signedBy = "signed_by"
        case dateSigned = "date_signed"
        case uploadcareImageUrl = "uploadcare_signature_image"
        case model
        case telepod
        case otherpaperwork
    }
    
    init(label : String?,signatureFileName : String?,signedBy : String?,dateSigned : String?,uploadcareImageUrl:String?,welldress:DriverQuestion = DriverQuestion.init(label: "Was our driver smartly dressed in uniform?", values: nil),driverexperience:DriverQuestion = DriverQuestion.init(label: "How was your experience?", values:nil),driverbehaviour:DriverQuestion =  DriverQuestion.init(label: "Was our driver Professional and Polite?", values:nil)
        ,model:SignatureConfirmation = SignatureConfirmation.init(label:"Model", values: nil)
        ,telepod:SignatureConfirmation = SignatureConfirmation.init(label: "Telepod", values: nil)
        ,otherpaperwork:SignatureConfirmation = SignatureConfirmation.init(label: "Other 3rd party paperwork", values: nil)) {
        self.label = label
        self.signatureFileName = signatureFileName
        self.signedBy = signedBy
        self.dateSigned = dateSigned
        self.uploadcareImageUrl = uploadcareImageUrl
        self.welldress = welldress
        self.driverexperience = driverexperience
        self.driverbehaviour = driverbehaviour
        self.model = model
        self.telepod = telepod
        self.otherpaperwork = otherpaperwork
    }
}
class DriverQuestion: NSObject,Codable {
    var label:String?
    var values:[String]?
    
    enum CodingKeys: String, CodingKey  {
        case label
        case values
    }
    init(label : String?,values : [String]?){
        self.label = label
        self.values = values ?? []
    }
}
class SignatureConfirmation: NSObject,Codable {
    var label:String?
    var values:[String]?
    
    enum CodingKeys: String, CodingKey  {
        case label
        case values
    }
    init(label : String?,values : [String]?){
        self.label = label
        self.values = values ?? []
    }
}
