//
//  MemoryDC.swift
//  CogniApp
//
//  Created by Dylan Bautista on 13/12/25.
//

import Foundation


class MemoryDomainController {
    
    // MARK: - Game Configuration
    let minLength = 2
    let maxLength = 8
    let seriesPerLength = 2
    let maxErrors = 2

    // MARK: - Game State
    var currentLength = 2
    var currentSeries = 0
    var errorCount = 0

    var currentSequence: [Int] = []
    var isGameOver = false

    // Input de l'usuari (paraules)
    var userSequence: [String] = []

    // MARK: - Game Flow

    func startGame() {
        currentLength = minLength
        currentSeries = 0
        errorCount = 0
        isGameOver = false
        nextRound()
    }

    func nextRound() {
        guard !isGameOver else { return }

        if errorCount >= maxErrors {
            endGame(success: false)
            return
        }

        if currentLength > maxLength {
            endGame(success: true)
            return
        }

        if currentSeries >= seriesPerLength {
            currentLength += 1
            currentSeries = 0
        }

        generateSequence()
        // La UI mostra currentSequence EN ORDRE NORMAL
        // Després cridarà getUserResponse(...)
    }

    // MARK: - Sequence Generation

    func generateSequence() {
        currentSequence = (0..<currentLength).map { _ in
            Int.random(in: 0...9)
        }
        print("SEQÜÈNCIA (normal): \(currentSequence)")
    }

    // MARK: - User Input

    func getUserResponse(userInput: [String]) {
        userSequence = userInput

        let userNumbers = convertWordsToNumbers(words: userSequence)
        checkAnswer(userNumbers: userNumbers)
    }

    // MARK: - Validation (ordre invers)

    func checkAnswer(userNumbers: [Int]) {
        let reversedSequence = Array(currentSequence.reversed())

        if userNumbers == reversedSequence {
            currentSeries += 1
            nextRound()
        } else {
            errorCount += 1
            nextRound()
        }
    }

    // MARK: - End Game

    func endGame(success: Bool) {
        isGameOver = true

        if success {
            print("🎉 Test completat amb èxit!")
        } else {
            print("❌ Joc acabat per errors.")
        }

        print("Llargada màxima assolida: \(currentLength)")
        print("Errors: \(errorCount)")
    }

    // MARK: - Utils

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
