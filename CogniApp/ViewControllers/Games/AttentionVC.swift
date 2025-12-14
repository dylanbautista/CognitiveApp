import UIKit

class AttentionVC: UIViewController {

    // MARK: - Voice Recorder
    let voiceRecorder = VoiceRecorder()
    let userService = UserService()
    let gameService = GameService()

    // MARK: - UI

    @IBOutlet var sequenceLabel: UILabel!

    // MARK: - Joc
    private var currentLength = 4
    private let maxLength = 9
    private let seriesPerLength = 2
    private var currentSeries = 0
    private var currentSequence: [Int] = []

    private var numErrors = 0
    private let maxErrors = 4
    private var isGameOver = false

    // MARK: - Temps
    private let roundDuration: TimeInterval = 10
    private var roundTimer: Timer?
    private var pollingTimer: Timer?
    private var elapsedTime: TimeInterval = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLabel()
        startGame()
    }

    private func setupLabel() {
        sequenceLabel.font = .systemFont(ofSize: 44, weight: .bold)
        sequenceLabel.textAlignment = .center
        sequenceLabel.numberOfLines = 0
    }

    // MARK: - Joc
    private func startGame() {
        currentLength = 4
        currentSeries = 0
        numErrors = 0
        isGameOver = false
        nextRound()
    }

    private func nextRound() {
        guard !isGameOver else { return }

        if numErrors >= maxErrors || currentLength > maxLength {
            finishGame()
            return
        }

        if currentSeries >= seriesPerLength {
            currentLength += 1
            currentSeries = 0
        }

        generateSequence()
        showSequence()
        startRound()
    }

    private func generateSequence() {
        currentSequence = (0..<currentLength).map {
            Int.random(_ in: 0...9)
        }
    }

    private func showSequence() {
        sequenceLabel.text = currentSequence.map(String.init).joined(separator: " ")
    }

    // MARK: - Ronda
    private func startRound() {
        elapsedTime = 0

        voiceRecorder.startRecording(paraules: true)

        startPolling()
        startRoundTimer()
    }

    private func endRound(success: Bool) {
        roundTimer?.invalidate()
        pollingTimer?.invalidate()
        voiceRecorder.stopRecording()

        if success {
            currentSeries += 1
        } else {
            numErrors += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.nextRound()
        }
    }

    // MARK: - Polling veu
    private func startPolling() {
        pollingTimer?.invalidate()

        pollingTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            let results = self.voiceRecorder.getSessionResults()
            let spokenNumbers = results.compactMap { Int($0) }
            print("Spoken numbers: \(spokenNumbers)")

            guard spokenNumbers.count >= self.currentSequence.count else { return }

            let lastSpoken = Array(
                spokenNumbers.suffix(self.currentSequence.count)
            )

            if lastSpoken == self.currentSequence {
                self.endRound(success: true)
            }
        }
    }

    // MARK: - Temporitzador de ronda
    private func startRoundTimer() {
        roundTimer?.invalidate()

        roundTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.elapsedTime += 0.1

            if self.elapsedTime >= self.roundDuration {
                self.endRound(success: false)
            }
        }
    }

    // MARK: - Final del joc
    private func finishGame() {
        isGameOver = true
        roundTimer?.invalidate()
        roundTimer = nil
        pollingTimer?.invalidate()
        pollingTimer = nil

        voiceRecorder.stopRecording()

        let finalErrors = self.numErrors
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
                        print("Error al guardar el resultado: \(error.localizedDescription)")
                    }
                }
            } else {
                print("No se pudo obtener el usuario. Resultado no guardado.")
            }


        let alert = UIAlertController(
            title: "Joc finalitzat",
            message: """
                     Errors: \(numErrors)
                     Longitud màxima assolida: \(currentLength)
                     """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
