//
//  FluencyDC.swift
//  CogniApp
//
//  Created by Dylan Bautista on 13/12/25.
//

import Foundation

class AuthDomainController {
    
    //let userService = UserService();
    
    func signUp(name : String, surname1 : String, surname2 : String, username: String, email : String, password: String, password2: String) throws {
        
        if (password != password2) { throw AuthError.DifferentPasswordsError }
        
        // Backend logic to be added
        //userService.signUp
        
    }
    
    func logIn(username : String, password : String) throws {
        
        // Backend logic to be added
        
    }
    
    func logOut() throws {
        
    }
}
