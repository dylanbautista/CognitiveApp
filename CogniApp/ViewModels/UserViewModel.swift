import Foundation
import Combine


class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    private var userService = UserService()
    
    init() {
        self.user = userService.currentUser()
    }
    
    func signUp(email: String, password: String, name: String, completion: @escaping (Result<User, Error>) -> Void) {
        userService.signUp(email: email, password: password, name: name) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.user = user
                }
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        userService.signIn(email: email, password: password) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.user = user
                }
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        userService.signOut { result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self.user = nil
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}