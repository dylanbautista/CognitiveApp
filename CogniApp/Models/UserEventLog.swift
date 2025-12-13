import Foundation

struct UserEventLog: Codable {
    let userId: String
    let optionId: String
    var date: Date
}
