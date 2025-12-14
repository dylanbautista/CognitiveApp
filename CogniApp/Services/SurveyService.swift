import FirebaseFirestore

class SurveyService {
    private let db = Firestore.firestore()
    private let collectionName = "UserEventLogs"

    // 1. Obtener el Log ÚNICO del día; devuelve nil si no existe
    func getTodayLogEntry(for userId: String, completion: @escaping (UserEventLog?) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())

        db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isEqualTo: today)
            .getDocuments { snapshot, error in
                if let _ = error {
                    completion(nil)
                } else {
                    // Esperamos que solo haya un documento por usuario/día
                    let log = snapshot?.documents.compactMap { try? $0.data(as: UserEventLog.self) }.first
                    completion(log)
                }
            }
    }

    // 2. Guardar o actualizar el UNICO log del usuario (maneja el array de IDs)
    func saveOrUpdateLogEntry(_ log: UserEventLog, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let logToSave = log
        let dateKey = Calendar.current.startOfDay(for: log.date)
        
        let data: [String: Any] = [
            "userId": logToSave.userId,
            "optionIds": logToSave.optionIds, // Array de IDs
            "date": dateKey
        ]
        
        let query = db.collection(collectionName)
            .whereField("userId", isEqualTo: logToSave.userId)
            .whereField("date", isEqualTo: dateKey)

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let doc = snapshot?.documents.first {
                // Si ya existe, actualiza el documento existente (reemplaza el array 'optionIds')
                self.db.collection(self.collectionName).document(doc.documentID).setData(data, merge: false) { err in
                    if let err = err { completion(.failure(err)) } else { completion(.success(())) }
                }
            } else {
                // Si no existe, crea un nuevo documento
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

    // Obtener logs de los últimos 7 días
    func fetchLastSevenDaysLogs(for userId: String, completion: @escaping ([UserEventLog]) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: today)!

        db.collection(collectionName)
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
