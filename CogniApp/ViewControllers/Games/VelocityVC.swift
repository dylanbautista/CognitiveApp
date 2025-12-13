//
//  VelocityVC.swift
//  CogniApp
//
//  Created by Dylan Bautista on 12/12/25.
//

import UIKit

class VelocityVC: UIViewController {

    @IBOutlet var buttons: [UIButton] = []

    var numbers = Array(1...9).shuffled()
    var expectedNumber = 1

    var timer: Timer?
    var elapsedTime: TimeInterval = 0
    var numErrors = 0;

    @IBOutlet var timeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        numErrors = 0;
        setupButtons()
        updateTimeLabel()
    }

    func setupButtons() {
        for i in 0..<9 {
            buttons[i].setTitle("\(numbers[i])", for: .normal)
            buttons[i].tag = numbers[i]
            buttons[i].addTarget(self, action: #selector(numberTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc func numberTapped(_ sender: UIButton) {

        // Iniciar el cronòmetre al primer clic
        if timer == nil {
            startTimer()
        }

        if sender.tag == expectedNumber {
            sender.isEnabled = false
            expectedNumber += 1

            if expectedNumber == 10 {
                finishGame()
            }
        } else {
            // Error → sumar 2 segons
            //elapsedTime += 2
            //updateTimeLabel()
            numErrors += 1
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.elapsedTime += 0.1
            self.updateTimeLabel()
        }
    }

    func updateTimeLabel() {
        timeLabel.text = String(format: "Temps: %.1f s", elapsedTime)
    }

    func finishGame() {
        timer?.invalidate()
        timer = nil

        let alert = UIAlertController(
            title: "Has acabat!",
            message: String(format: "Temps final: %.1f segons. Amb %d errors!", elapsedTime, numErrors),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
