//
//  FluencyDC.swift
//  CogniApp
//
//  Created by Dylan Bautista on 13/12/25.
//

import Foundation

class AttentionDomainController {

    /*let ViewController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AttentionVC")*/
    
    var currentLength = 4
    let maxLength = 9
    let seriesPerLength = 2

    var currentSeries = 0
    var currentSequence: [Int] = []
    var isGameOver = false

    // Input de l'usuari
    var userSequence: [String] = []

    func startGame() {
        currentLength = 4
        currentSeries = 0
        isGameOver = false
        nextRound()
    }

    func nextRound() {
        guard !isGameOver else { return }

        if currentLength > maxLength {
            endGame(success: true)
            return
        }

        if currentSeries >= seriesPerLength {
            currentLength += 1
            currentSeries = 0
        }

        generateSequence()

        /*ViewController.showSequence(sequence: currentSequence)*/
        // Aquí el controlador extern mostrarà la seqüència
        // i després cridarà getUserResponse(...)
    }

    func generateSequence() {
        currentSequence = (0..<currentLength).map { _ in
            Int.random(in: 0...9)
        }
    }

    func getUserResponse(userInput: [String]) {
        userSequence = userInput

        /*let userNumbers = convertWordsToNumbers(userSequence)
        checkAnswer(userNumbers: userNumbers)*/
    }

    func checkAnswer(userNumbers: [Int]) {
        if userNumbers == currentSequence {
            currentSeries += 1
            nextRound()
        } else {
            endGame(success: false)
        }
    }

    func endGame(success: Bool) {
        isGameOver = true

        if success {
            // Congratulate player
        } 
        
        // Show results to tha player and go back to main menu
    }

    func convertWordsToNumbers(words: [String]) -> [Int] {
        let map: [String: Int] = [
            "zero": 0,
            "un": 1,
            "dos": 2,
            "tres": 3,
            "quatre": 4,
            "cinc": 5,
            "sis": 6,
            "set": 7,
            "vuit": 8,
            "nou": 9
        ]

        return words.compactMap { map[$0.lowercased()] }
    }
}
