//
//  VelocityVC.swift
//  CogniApp
//
//  Created by Dylan Bautista on 12/12/25.
//

import UIKit

class VelocityVC: UIViewController {

    var buttons: [UIButton] = []

    var numbers = Array(1...9).shuffled()
    var expectedNumber = 1

    var timer: Timer?
    var elapsedTime: TimeInterval = 0

    @IBOutlet weak var timeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        updateTimeLabel()
    }

    func setupButtons() {
        for i in 0..<9 {
            let button = UIButton(type: .system)
            button.setTitle("\(numbers[i])", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
            button.tag = numbers[i]
            button.addTarget(self, action: #selector(numberTapped(_:)), for: .touchUpInside)

            buttons.append(button)
            view.addSubview(button)

            // Posicionament simple (exemple)
            let row = i / 3
            let col = i % 3
            button.frame = CGRect(x: 60 + col * 80,
                                y: 150 + row * 80,
                                width: 60,
                                height: 60)
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
            elapsedTime += 2
            updateTimeLabel()
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
            message: String(format: "Temps final: %.1f segons", elapsedTime),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}