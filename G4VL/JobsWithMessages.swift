// To parse the JSON, add this file to your project and do:
//
//   let jobsWithMessages = try? newJSONDecoder().decode(JobsWithMessages, from: jsonData)

import Foundation

typealias JobsWithMessages = [JobWithMessages]

public class JobWithMessages: Codable {
    public let jobID: Int
    public let journeyDescription: String
    public var messages: [Message]
    
    enum CodingKeys: String, CodingKey {
        case jobID = "jobId"
        case journeyDescription = "journey_description"
        case messages
    }
    
    public init(jobID: Int, journeyDescription: String, messages: [Message]) {
        self.jobID = jobID
        self.journeyDescription = journeyDescription
        self.messages = messages
    }
}
