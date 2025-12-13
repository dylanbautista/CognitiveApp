import Foundation
import AnyCodable

struct GameResult: Codable {
    let userId: String
    let gameType: GameType
    let date: Date
    let additionalData: [String: AnyCodable]?
}
