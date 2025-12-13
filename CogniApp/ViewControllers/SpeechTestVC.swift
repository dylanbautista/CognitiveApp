//
//  ViewController.swift
//  CogniApp
//
//  Created by Dylan Bautista on 12/12/25.
//

import UIKit

class SpeechViewController: UIViewController {
    
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    
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
    
    
    //UIElements
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
   
    @IBAction func startPush(_ sender: Any) {
        
    }
    
    @IBAction func stopPush(_ sender: Any) {
    }
    
}

