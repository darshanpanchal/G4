// To parse the JSON, add this file to your project and do:
//
//   let messages = try? newJSONDecoder().decode(Messages.self, from: jsonData)

import Foundation

typealias Messages = [Message]

public class Message: Codable {
    public let id, jobID, driverID: Int?
    public let sentToDriverAt, readByDriverAt, messageType, messageContent: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case jobID = "job_id"
        case driverID = "driver_id"
        case sentToDriverAt = "sent_to_driver_at"
        case readByDriverAt = "read_by_driver_at"
        case messageType = "message_type"
        case messageContent = "message_content"
    }
    
    public init(id: Int?, jobID: Int?, driverID: Int?, sentToDriverAt: String?, readByDriverAt: String?, messageType: String?, messageContent: String?) {
        self.id = id
        self.jobID = jobID
        self.driverID = driverID
        self.sentToDriverAt = sentToDriverAt
        self.readByDriverAt = readByDriverAt
        self.messageType = messageType
        self.messageContent = messageContent
    }
}
