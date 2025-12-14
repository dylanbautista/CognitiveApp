import Foundation
import FirebaseFirestore
// Nota: UserEventLog debe ser una struct/clase que conforme a Codable/Decodable de Firebase.

// --- ESTRUCTURAS DE APOYO NECESARIAS ---

// Estructura de la recomendación (la usaremos en el completion handler)
struct Recommendation {
    let recommendedGame: GameType? // Juego interno (puede ser nil)
    let reasonDomain: UserEventDomain
    let frequency: Int
    let externalActivities: [ExternalRecommendation] // Actividades externas hardcodeadas
}

// Asegúrate de que UserEventOption y userEventOptions estén definidas correctamente
// y que UserEventDomain esté definida (como en la respuesta anterior).

// --- CLASE PRINCIPAL ---

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
        
        // Datos a guardar en Firestore
        let data: [String: Any] = [
            "userId": logToSave.userId,
            "optionIds": logToSave.optionIds, // Array de IDs de los síntomas seleccionados
            "date": dateKey
        ]
        
        // Consulta para ver si ya existe un log hoy
        let query = db.collection(collectionName)
            .whereField("userId", isEqualTo: logToSave.userId)
            .whereField("date", isEqualTo: dateKey)

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let doc = snapshot?.documents.first {
                // Si ya existe, actualiza el documento existente
                self.db.collection(self.collectionName).document(doc.documentID).setData(data, merge: false) { err in
                    if let err = err { completion(.failure(err)) } else { completion(.success(())) }
                }
            } else {
                // Si no existe, crea un nuevo documento
                do {
                    // Usamos addDocument(from:) si UserEventLog es Codable, pero usamos setData/addDocument(data)
                    // para asegurar que el campo "date" sea el inicio del día para la consulta.
                    
                    self.db.collection(self.collectionName).addDocument(data: data) { err in
                        if let err = err { completion(.failure(err)) } else { completion(.success(())) }
                    }
                }
            }
        }
    }

    // 3. Obtener logs de los últimos 7 días
    func fetchLastSevenDaysLogs(for userId: String, completion: @escaping ([UserEventLog]) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())
        // Buscamos 7 días de datos, incluyendo hoy (hoy - 6 días = inicio del periodo)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: today)!

        db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: sevenDaysAgo)
            // No es estrictamente necesario, pero asegura que no haya documentos futuros
            .whereField("date", isLessThanOrEqualTo: today) 
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error al consultar logs: \(error)")
                    completion([])
                    return
                }
                
                // Mapeamos los documentos a la estructura UserEventLog (debe ser Decodable)
                let logs = snapshot?.documents.compactMap { try? $0.data(as: UserEventLog.self) } ?? []
                completion(logs)
            }
    }
}

// MARK: - Lógica de Recomendación (Extension)

extension SurveyService {

    /// Analiza los logs de los últimos 7 días y recomienda un juego + actividades.
    ///
    /// Encuentra el dominio cognitivo con el mayor número de reportes de síntomas.
    func getTopRecommendation(for userId: String, completion: @escaping (Recommendation?) -> Void) {
        
        fetchLastSevenDaysLogs(for: userId) { logs in
            guard !logs.isEmpty else {
                completion(nil) // No hay logs en los últimos 7 días
                return
            }

            // 1. Recuento de dominios afectados
            var domainCounts: [UserEventDomain: Int] = [:]
            
            for log in logs {
                let symptomIds = log.optionIds
                
                // Mapear IDs de síntomas a Dominios afectados y contar
                for optionId in symptomIds {
                    // userEventOptions debe estar disponible globalmente o inyectado aquí
                    if let option = userEventOptions.first(where: { $0.id == optionId }) {
                        let domain = option.domain
                        domainCounts[domain, default: 0] += 1
                    }
                }
            }

            // 2. Encontrar el Dominio más afectado
            let topEntry = domainCounts.max { a, b in a.value < b.value }
            
            guard let (topDomain, frequency) = topEntry else {
                completion(nil)
                return
            }

            // 3. Cargar recomendaciones (Juego Interno y Actividades Externas)
            let recommendedGame = topDomain.recommendedGame
            // hardcodedActivities debe estar disponible globalmente o inyectado aquí
            let externalActivities = hardcodedActivities[topDomain] ?? [] 
            
            // 4. Devolver la recomendación
            let recommendation = Recommendation(
                recommendedGame: recommendedGame,
                reasonDomain: topDomain,
                frequency: frequency,
                externalActivities: externalActivities
            )
            completion(recommendation)
        }
    }
}