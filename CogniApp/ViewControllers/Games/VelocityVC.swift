//
//  VelocityVC.swift
//  CogniApp
//
//  Created by Dylan Bautista on 12/12/25.
//

import UIKit
import Foundation
import AnyCodable

class VelocityVC: UIViewController {

    let userService = UserService()
    let gameService = GameService()

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
            // Error: sumar 2 segons
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
        
        // 1. Detener el temporizador inmediatamente
        timer?.invalidate() 
        timer = nil

        // Guardamos las variables locales antes de llamar a la función asíncrona
        let finalTime = self.elapsedTime
        let finalErrors = self.numErrors
        
        // 2. OBTENER EL USUARIO ASÍNCRONAMENTE
        userService.fetchCurrentUser { [weak self] result in
            
            guard let self = self else { return }
            
            // 3. Intentar guardar el resultado solo si hay un usuario logueado
            if case .success(let user) = result {
                
                // Crear el objeto GameResult con el ID del usuario
                let resultToSave = GameResult(
                    userId: user.id,
                    gameType: .processingSpeed, // Usamos .processingSpeed como ejemplo del enum
                    date: Date(),
                    additionalData: [
                        "time": AnyCodable(finalTime),
                        "errors": AnyCodable(finalErrors)
                    ]
                )
                
                // Llamar a la función de guardado (asíncrona)
                self.gameService.saveGameResult(resultToSave) { saveResult in
                    if case .failure(let error) = saveResult {
                        print("❌ Error al guardar el resultado: \(error.localizedDescription)")
                    } else {
                        print("✅ Resultado de juego guardado con éxito.")
                    }
                }
            } else {
                print("🛑 No se pudo obtener el usuario. Resultado no guardado.")
            }
            
            // 4. Mostrar la alerta de fin de juego (siempre)
            // Aseguramos que la UI se actualice en el hilo principal
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Has acabat!",
                    message: String(format: "Temps final: %.1f segons. Amb %d errors!", finalTime, finalErrors),
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
