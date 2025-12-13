import Foundation

struct UserEventLog: Identifiable, Codable {
    let id: String
    let userId: String
    let optionId: String
    let date: Date
}