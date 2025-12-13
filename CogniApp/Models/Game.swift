
enum GameType: String, Codable,CaseIterable {
    case fluency
    case attention
    case workingMemory
    case processingSpeed


    var title: String {
        switch self {
        case .fluency:
            return "Fluency"
        case .attention:
            return "Attention"
        case .workingMemory:
            return "Working Memory"
        case .processingSpeed:
            return "Processing Speed"
        }
    }

    func instructions(dynamicText: String? = nil) -> String {
        switch self {
        case .workingMemory:
            return "Remember the sequence of cards shown on the screen."
        case .processingSpeed:
            return "Tap the targets as fast as you can before time runs out."
        case .attention:
            return "Focus and identify the correct items among distractors."
        case .fluency:
            return "Say as many words as possible within the category shown."
        }
    }

    var instructionDuration: Int {15}
}
