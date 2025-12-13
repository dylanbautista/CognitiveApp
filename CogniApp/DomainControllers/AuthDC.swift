//
//  FluencyDC.swift
//  CogniApp
//
//  Created by Dylan Bautista on 13/12/25.
//

import Foundation

class AuthDomainController {
    
    let userService = UserService();
    
    func signUp(name : String, surname1 : String, surname2 : String, username: String, email : String, password: String, password2: String) throws {
        
        if (password != password2) { throw AuthError.DifferentPasswordsError }
        
        // Backend logic to be added
        userService.signUp(
            email: email,
            password: password,
            name: name,
            surname: surname1,
            surname2: surname2,
        ) { result in
            switch result {
            case .success(let user):
                print("Usuario creado: \(user.name) \(user.surname)")
                // Aquí puedes navegar a la pantalla principal de la app
            case .failure(let error):
                print("Error al crear usuario: \(error.localizedDescription)")
                // Aquí puedes mostrar un alert al usuario
            }
        }
        
    }
    
    func logIn(username : String, password : String) throws {
        
        // Backend logic to be added
        
    }
    
    func logOut() throws {
        
    }
}
