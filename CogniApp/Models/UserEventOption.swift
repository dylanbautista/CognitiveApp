import Foundation

struct UserEventOption: Identifiable, Codable {
    let id: String
    let text: String
    let domain: CognitiveDomain
}

enum CognitiveDomain: String, Codable {
    case attention
    case speedProcessing
    case verbalFluency
    case memory
    case executiveFunctions
}