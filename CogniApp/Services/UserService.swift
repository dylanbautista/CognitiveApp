import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserService {

    private let db = Firestore.firestore()


    func signUp(email: String, password: String, name: String, completion: @escaping (Result<User, Error>) -> Void) {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    completion(.failure(error)) // devolver error si ocurre
                } else if let firebaseUser = result?.user {
                    let userData = [
                        "name": name,
                        "email": email,
                        "createdAt": FieldValue.serverTimestamp()
                    ]
                    self.db.collection("users").document(firebaseUser.uid).setData(userData) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(firebaseUser))
                        }
                    }
                }
            }
        }


    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error)) // devolver error si ocurre
            } else if let firebaseUser = result?.user {
                completion(.success(firebaseUser)) // devolver usuario autenticado
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


    func currentUser() -> User? {
        return Auth.auth().currentUser // devolver el usuario actual si existe
    }

}