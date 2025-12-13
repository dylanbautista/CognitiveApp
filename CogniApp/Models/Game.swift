struct Game: Identifiable, Codable {
    let id: String
    let type: GameType
    let description: String
}

enum GameType: String, Codable {
    case fluency
    case attention
    case workingMemory
    case processingSpeed
}