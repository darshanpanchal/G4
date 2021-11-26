// To parse the JSON, add this file to your project and do:
//
//   let jobs = try? newJSONDecoder().decode(Jobs.self, from: jsonData)

import Foundation

typealias Jobs = [Job]

class Job: Codable, Equatable {
    static func == (lhs: Job, rhs: Job) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id, driverId: Int?
    let pickupDay, pickupMonth, pickupYear: String?
    let pickupTime: String?
    let dropoffDay, dropoffMonth, dropoffYear: String?
    let dropoffTime: String?
    let fleetPaperworkRequired, suggestedOrder: Int?
    let status: JobStatus?
    let specialInstructions: String?
    let collectSignature, manualAppraisalRequired, videoAppraisalRequired: Int?
    let nameOfExternalSystemForAppraisal: String?
    let appraisalToBeDoneOnExternalSystem: Int?
    let createdAt, updatedAt: String?
    let jetWashRequired: Int?
    let pusherChannel: String?
    let dropoffAddress, pickupAddress: Address?
    let customer: Customer?
    let vehicle: Vehicle?
    let pickupPreposition : Preposition?
    let dropoffPreposition : Preposition?
    var driverDocuments : [DriverDocument] = []
    var splitSequence:String?
    let minimumFuel:Int?
    let keytokey:String?
    let schedulePickUpDay, schedulePickUpMonth, schedulePickUpYear, schedulePickUpTime:String?
    let scheduleDropOffDay, scheduleDropOffMonth, scheduleDropOffYear, scheduleDropOffTime:String?
  
    enum CodingKeys: String, CodingKey {
        case id
        case driverId = "driver_id"
        case pickupPreposition = "pickup_preposition"
        case pickupDay = "pickup_day"
        case pickupMonth = "pickup_month"
        case pickupYear = "pickup_year"
        case pickupTime = "pickup_time"
        case dropoffPreposition = "dropoff_preposition"
        case dropoffDay = "dropoff_day"
        case dropoffMonth = "dropoff_month"
        case dropoffYear = "dropoff_year"
        case dropoffTime = "dropoff_time"
        case fleetPaperworkRequired = "fleet_paperwork_required"
        case suggestedOrder = "suggested_order"
        case status
        case specialInstructions = "special_instructions"
        case collectSignature = "collect_signature"
        case manualAppraisalRequired = "manual_appraisal_required"
        case videoAppraisalRequired = "video_appraisal_required"
        case nameOfExternalSystemForAppraisal = "name_of_external_system_for_appraisal"
        case appraisalToBeDoneOnExternalSystem = "appraisal_to_be_done_on_external_system"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case jetWashRequired = "jet_wash_required"
        case pusherChannel = "pusher_channel"
        case dropoffAddress = "dropoff_address"
        case pickupAddress = "pickup_address"
        case driverDocuments = "driver_documents"
        case customer, vehicle
        case splitSequence = "split_sequence"
        case minimumFuel = "minimum_fuel_amount_in_pense"
        case keytokey = "key_to_key_end_reg"
        case schedulePickUpDay = "scheduled_pickup_day"
        case schedulePickUpMonth = "scheduled_pickup_month"
        case schedulePickUpYear = "scheduled_pickup_year"
        case schedulePickUpTime = "scheduled_pickup_time"
        case scheduleDropOffDay = "scheduled_dropoff_day"
        case scheduleDropOffMonth = "scheduled_dropoff_month"
        case scheduleDropOffYear = "scheduled_dropoff_year"
        case scheduleDropOffTime = "scheduled_dropoff_time"
        
    }
    
    init(id: Int?, driverId: Int?, pickupPreposition: Preposition?, pickupDay: String?, pickupMonth: String?, pickupYear: String?, pickupTime: String?, dropoffPreposition: Preposition?, dropoffDay: String?, dropoffMonth: String?, dropoffYear: String?, dropoffTime: String?, fleetPaperworkRequired: Int?, suggestedOrder: Int?, status: JobStatus?, specialInstructions: String?, collectSignature: Int?, manualAppraisalRequired: Int?, videoAppraisalRequired: Int?, nameOfExternalSystemForAppraisal: String?, appraisalToBeDoneOnExternalSystem: Int?, createdAt: String?, updatedAt: String?, jetWashRequired: Int?, pusherChannel: String?, dropoffAddress: Address?, pickupAddress: Address?, customer: Customer?, vehicle: Vehicle?, driverDocuments:[DriverDocument]?,splitSequence:String?,minimumFuel:Int?,keytokey:String?,schedulePickUpDay:String?, schedulePickUpMonth:String?, schedulePickUpYear:String?, schedulePickUpTime:String?,scheduleDropOffDay:String?, scheduleDropOffMonth:String?, scheduleDropOffYear:String?, scheduleDropOffTime:String?) {
        self.id = id
        self.driverId = driverId
        self.pickupPreposition = pickupPreposition
        self.pickupDay = pickupDay
        self.pickupMonth = pickupMonth
        self.pickupYear = pickupYear
        self.pickupTime = pickupTime
        self.dropoffPreposition = dropoffPreposition
        self.dropoffDay = dropoffDay
        self.dropoffMonth = dropoffMonth
        self.dropoffYear = dropoffYear
        self.dropoffTime = dropoffTime
        self.fleetPaperworkRequired = fleetPaperworkRequired
        self.suggestedOrder = suggestedOrder
        self.status = status
        self.specialInstructions = specialInstructions
        self.collectSignature = collectSignature
        self.manualAppraisalRequired = manualAppraisalRequired
        self.videoAppraisalRequired = videoAppraisalRequired
        self.nameOfExternalSystemForAppraisal = nameOfExternalSystemForAppraisal
        self.appraisalToBeDoneOnExternalSystem = appraisalToBeDoneOnExternalSystem
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.jetWashRequired = jetWashRequired
        self.pusherChannel = pusherChannel
        self.dropoffAddress = dropoffAddress
        self.pickupAddress = pickupAddress
        self.customer = customer
        self.vehicle = vehicle
        self.driverDocuments = driverDocuments ?? []
        self.splitSequence = splitSequence
        self.minimumFuel = minimumFuel
        self.keytokey = keytokey
        self.schedulePickUpDay = schedulePickUpDay
        self.schedulePickUpMonth = schedulePickUpMonth
        self.schedulePickUpYear = schedulePickUpYear
        self.schedulePickUpTime = schedulePickUpTime
        self.scheduleDropOffDay = scheduleDropOffDay
        self.scheduleDropOffMonth = scheduleDropOffMonth
        self.scheduleDropOffYear = scheduleDropOffYear
        self.scheduleDropOffTime = scheduleDropOffTime
    }
 /*
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(Int.self, forKey: .id)
        self.driverId =  try values.decodeIfPresent(Int.self, forKey: .driverId)
        self.pickupPreposition =  try values.decodeIfPresent(Preposition.self, forKey: .pickupPreposition)
        self.pickupDay = try values.decodeIfPresent(String.self, forKey: .pickupDay)
        self.pickupMonth = try values.decodeIfPresent(String.self, forKey: .pickupMonth) // pickupMonth
        self.pickupYear = try values.decodeIfPresent(String.self, forKey: .pickupYear)
        self.pickupTime = try values.decodeIfPresent(String.self, forKey: .pickupTime)
        self.dropoffPreposition = try values.decodeIfPresent(Preposition.self, forKey: .dropoffPreposition)
        self.dropoffDay = try values.decodeIfPresent(String.self, forKey: .dropoffDay)
        self.dropoffMonth = try values.decodeIfPresent(String.self, forKey: .dropoffMonth)
        self.dropoffYear = try values.decodeIfPresent(String.self, forKey: .dropoffYear)
        self.dropoffTime = try values.decodeIfPresent(String.self, forKey: .dropoffTime)
        self.fleetPaperworkRequired = try values.decodeIfPresent(Int.self, forKey: .fleetPaperworkRequired)
        self.suggestedOrder = try values.decodeIfPresent(Int.self, forKey: .suggestedOrder)
        self.status = try values.decodeIfPresent(JobStatus.self, forKey: .status)
        self.specialInstructions = try values.decodeIfPresent(String.self, forKey: .specialInstructions)
        self.collectSignature = try values.decodeIfPresent(Int.self, forKey: .collectSignature)
        self.manualAppraisalRequired = try values.decodeIfPresent(Int.self, forKey: .manualAppraisalRequired)
        self.videoAppraisalRequired = try values.decodeIfPresent(Int.self, forKey: .videoAppraisalRequired)
        self.nameOfExternalSystemForAppraisal = try values.decodeIfPresent(String.self, forKey: .nameOfExternalSystemForAppraisal)
        self.appraisalToBeDoneOnExternalSystem = try values.decodeIfPresent(Int.self, forKey: .appraisalToBeDoneOnExternalSystem)
        self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        self.jetWashRequired = try values.decodeIfPresent(Int.self, forKey: .jetWashRequired)
        self.pusherChannel = try values.decodeIfPresent(String.self, forKey: .pusherChannel)
        self.dropoffAddress = try values.decodeIfPresent(Address.self, forKey: .dropoffAddress)
        self.pickupAddress = try values.decodeIfPresent(Address.self, forKey: .pickupAddress)
        self.customer = try values.decodeIfPresent(Customer.self, forKey: .customer)
        self.vehicle = try values.decodeIfPresent(Vehicle.self, forKey: .vehicle)
        self.driverDocuments = try values.decodeIfPresent([DriverDocument].self, forKey: .driverDocuments) ?? []
        self.splitSequence = try values.decodeIfPresent(String.self, forKey: .splitSequence)
        self.minimumFuel = try values.decodeIfPresent(Int.self, forKey: .minimumFuel)
    }*/
    func getPickupDate() -> String {
        return "\(pickupDay!)/\(pickupMonth!)/\(pickupYear!)"
    }
    func getDropOffDate() -> String {
        return "\(pickupDay!)/\(pickupMonth!)/\(pickupYear!)"
    }
    func getSchedulePickupDateAndTime()->String{
        return "\(schedulePickUpDay ?? "")/\(schedulePickUpMonth ?? "" )/\(schedulePickUpYear ?? "") \(schedulePickUpTime ?? "")"
    }
    func getScheduleDropOffDateAndTime()->String{
        return "\(scheduleDropOffDay ?? "")/\(scheduleDropOffMonth ?? "")/\(scheduleDropOffYear ?? "") \(scheduleDropOffTime ?? "")"
    }
}







