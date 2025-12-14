import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserService {

    private let db = Firestore.firestore()


    func signUp(email: String, password: String, name: String, surname: String, surname2: String?, completion: @escaping (Result<User, Error>) -> Void) {
        
        // 1. ELIMINADA LA LLAMADA DUPLICADA. Solo queda esta:
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                // Manejo de error explícito para depuración
                let nsError = error as NSError
                print("--------------------------------------------------")
                print("❌ ERROR al crear usuario (CÓDIGO \(nsError.code)):")
                print("Mensaje: \(error.localizedDescription)")
                print("Dominio: \(nsError.domain)")
                print("--------------------------------------------------")
                
                completion(.failure(error))
                return // Salir del closure si hay error
                
            } else if let firebaseUser = result?.user {
                // 2. Éxito en la creación del usuario en Auth
                
                let user = User(
                    id: firebaseUser.uid,
                    name: name,
                    surname: surname,
                    surname2: surname2,
                    email: email
                )
                
                // Guardar en Firestore
                let userData: [String: Any] = [
                    "name": user.name,
                    "surname": user.surname,
                    "surname2": user.surname2 ?? "",
                    "email": user.email,
                    "createdAt": FieldValue.serverTimestamp()
                ]
                
                self.db.collection("users").document(user.id).setData(userData) { dbError in
                    if let dbError = dbError {
                        print("❌ ERROR al guardar datos en Firestore: \(dbError.localizedDescription)")
                        completion(.failure(dbError))
                    } else {
                        print("🎉 Usuario \(user.id) creado y guardado en Firestore con éxito.")
                        completion(.success(user))
                    }
                }
            }
        }
    }


    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let firebaseUser = result?.user {
                // Obtener datos completos de Firestore
                self.db.collection("users").document(firebaseUser.uid).getDocument { snapshot, dbError in
                    if let dbError = dbError {
                        completion(.failure(dbError))
                    } else if let data = snapshot?.data() {
                        // Mapear Firestore data a tu struct User
                        let user = User(
                            id: firebaseUser.uid,
                            name: data["name"] as? String ?? "",
                            surname: data["surname"] as? String ?? "",
                            surname2: data["surname2"] as? String,
                            email: data["email"] as? String ?? ""
                        )
                        completion(.success(user))
                    } else {
                        completion(.failure(NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado en Firestore"])))
                    }
                }
            }
        }
    }


    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(())) // devolver éxito
        } catch let signOutError as NSError {
            completion(.failure(signOutError)) // devolver error si ocurre
        }
    }

    // En UserService.swift

// NUEVA FUNCIÓN: Obtiene el usuario autenticado y sus datos de Firestore
    func fetchCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        
        // 1. Verificar si hay alguien logueado en Firebase Auth
        guard let firebaseUser = Auth.auth().currentUser else {
            let error = NSError(
                domain: "UserService", 
                code: 401, 
                userInfo: [NSLocalizedDescriptionKey: "No hay un usuario autenticado"]
            )
            completion(.failure(error))
            return
        }

        // 2. Usar el UID para obtener el documento completo de Firestore
        self.db.collection("users").document(firebaseUser.uid).getDocument { snapshot, dbError in
            
            if let dbError = dbError {
                completion(.failure(dbError))
            } else if let data = snapshot?.data() {
                
                // 3. Mapear los datos de Firestore a tu struct User
                let user = User(
                    id: firebaseUser.uid,
                    name: data["name"] as? String ?? "",
                    surname: data["surname"] as? String ?? "",
                    surname2: data["surname2"] as? String,
                    email: data["email"] as? String ?? ""
                )
                completion(.success(user))
                
            } else {
                // Usuario en Auth, pero no en Firestore
                let error = NSError(
                    domain: "UserService", 
                    code: 404, 
                    userInfo: [NSLocalizedDescriptionKey: "Datos de usuario no encontrados en Firestore"]
                )
                completion(.failure(error))
            }
        }
    }
}



