//
//  ViewController.swift
//  CogniApp
//
//  Created by Dylan Bautista on 12/12/25.
//

import UIKit

class UserDataViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            // Your custom setup here
    }
    
    required init?(coder: NSCoder) {
            super.init(coder: coder)
            // Or, if you don’t support storyboard initialization:
            fatalError("init(coder:) has not been implemented")
    }
    
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
    let name : String;
    let surname1 : String;
    let surname2 : String;
    let username : String;
    let mail : String;
    let password : String;
    let password2 : String;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /*func initDomainController(controller : AuthDomainController) {
        domainController = controller;
    }*/
    
    @IBAction func nextButton(_ sender: Any) {
        domainController.signUp(name: name, surname1: surname1, surname2: surname2, username: username, email: mail, password: password, password2: password2)
        
    }
    
    
}

