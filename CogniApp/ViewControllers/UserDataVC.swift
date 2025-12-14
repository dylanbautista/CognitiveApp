//
//  ViewController.swift
//  CogniApp
//
//  Created by Dylan Bautista on 12/12/25.
//

import UIKit

class UserDataViewController: UIViewController {
    
    
    //Domain Controller
    let domainController = AuthDomainController()
    
    //UIElements
    @IBOutlet var nameTF: UITextField!
    @IBOutlet var surnamesTF: UITextField!
    @IBOutlet var usernameTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var password2TF: UITextField!
    
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    
    // SingUpValues
    var name : String = "";
    var surname1 : String = "";
    var surname2 : String = "";
    var username : String = "";
    var mail : String = "";
    var password : String = "";
    var password2 : String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /*func initDomainController(controller : AuthDomainController) {
        domainController = controller;
    }*/
    
    @IBAction func nextButton(_ sender: Any) {
        do {
            try domainController.signUp(name: nameTF.text!, surname1: surnamesTF.text!, surname2: surnamesTF.text!, username: usernameTF.text!, email: emailTF.text!, password: passwordTF.text!, password2: password2TF.text!)
            print(nameTF.text!);
        } catch {print("error")}
        
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    
    
    
}

