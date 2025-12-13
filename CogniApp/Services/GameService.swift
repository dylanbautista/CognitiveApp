import FirebaseFirestore

class GameService {
    private let db = Firestore.firestore()

    func saveGameResult(_ result: GameResult, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection("gameResults").addDocument(from: result) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }

    func fetchGameResults(forUserId userId: String, completion: @escaping (Result<[GameResult], Error>) -> Void) {
        db.collection("gameResults").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let results: [GameResult] = snapshot?.documents.compactMap { document in
                    return try? document.data(as: GameResult.self)
                } ?? []
                completion(.success(results))
            }
        }
    }

    func fetchGameResults(forGameType gameType: GameType, completion: @escaping (Result<[GameResult], Error>) -> Void) {
        db.collection("gameResults").whereField("gameType", isEqualTo: gameType.rawValue).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let results: [GameResult] = snapshot?.documents.compactMap { document in
                    return try? document.data(as: GameResult.self)
                } ?? []
                completion(.success(results))
            }
        }
    }
}