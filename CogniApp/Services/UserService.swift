import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserService {

    private let db = Firestore.firestore()


    func signUp(email: String, password: String, name: String, surname: String, surname2: String?, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let firebaseUser = result?.user {
                // Crear tu struct User
                let user = User(
                    id: firebaseUser.uid,
                    name: name,
                    surname: surname,
                    surname2: surname2,
                    email: email,
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
                        completion(.failure(dbError))
                    } else {
                        completion(.success(user)) // Devolver tu User, no firebaseUser
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


    

}
