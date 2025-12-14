import Foundation

struct UserEventLog: Codable {
    let userId: String
    var optionIds: [String]
    var date: Date
}
