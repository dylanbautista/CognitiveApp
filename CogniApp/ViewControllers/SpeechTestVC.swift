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
    
    //Domain Controller
    //let recorder = VoiceRecorder();
    
    //UIElements
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
   
    @IBAction func startPush(_ sender: Any) {
        /*Task {
            do {
                try await recorder.startVoiceRecording()
            } catch {
                print("Error: ", error)
            }
        }*/
        
    }
    
    @IBAction func stopPush(_ sender: Any) {
        //recorder.stopVoiceRecording()
    }
    
}

