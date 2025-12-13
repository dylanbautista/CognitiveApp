//
//  ViewController.swift
//  CogniApp
//
//  Created by Dylan Bautista on 12/12/25.
//

import UIKit

class MemoryVC: UIViewController {
    
    var domainController : MemoryDomainController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func initDomainController(controller : MemoryDomainController) {
        self.domainController = controller
    }
    
    
}

