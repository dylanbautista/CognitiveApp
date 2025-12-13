import FirebaseFirestore
import FirebaseFirestoreSwift

class SurveyService {
    private let db = Firestore.firestore()
    private let collectionName = "UserEventLogs"

    // Obtener log del día; devuelve nil si no existe
    func getTodayLog(for userId: String, completion: @escaping (UserEventLog?) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())

        db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isEqualTo: today)
            .getDocuments { snapshot, error in
                if let _ = error {
                    completion(nil)
                } else {
                    let log = snapshot?.documents.compactMap { try? $0.data(as: DailyUserEventLog.self) }.first
                    completion(log)
                }
            }
    }

    // Guardar o actualizar log con las respuestas del usuario
    func saveOrUpdate(_ log: UserEventLog, completion: @escaping (Result<Void, Error>) -> Void) {
        var logToSave = log
        logToSave.date = Calendar.current.startOfDay(for: log.date)
        let query = db.collection(collectionName)
            .whereField("userId", isEqualTo: logToSave.userId)
            .whereField("date", isEqualTo: logToSave.date)

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let doc = snapshot?.documents.first {
                db.collection(self.collectionName).document(doc.documentID).setData([
                    "eventStatuses": logToSave.eventStatuses
                ], merge: true) { err in
                    if let err = err { completion(.failure(err)) } else { completion(.success(())) }
                }
            } else {
                do {
                    let _ = try self.db.collection(self.collectionName).addDocument(from: logToSave) { err in
                        if let err = err { completion(.failure(err)) } else { completion(.success(())) }
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    func fetchLastSevenDaysLogs(for userId: String, completion: @escaping ([UserEventLog]) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: today)!

        db.collection("UserEventLogs")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: sevenDaysAgo)
            .whereField("date", isLessThanOrEqualTo: today)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error al consultar logs: \(error)")
                    completion([])
                    return
                }

                let logs = snapshot?.documents.compactMap { try? $0.data(as: UserEventLog.self) } ?? []
                completion(logs)
            }
    }

}
