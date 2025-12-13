import Foundation

struct UserEventOption: Identifiable, Codable {
    let id: String
    let text: String
    let domain: CognitiveDomain
}

