import Foundation

struct UserEventLog: Identifiable, Codable {
    let userId: String
    let optionId: String
    let date: Date
}