import UIKit

class AttentionVC: UIViewController {

    // MARK: - Voice Recorder
    let voiceRecorder = VoiceRecorder()

    // MARK: - UI
    private let sequenceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 44, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Joc
    private var currentLength = 4
    private let maxLength = 9
    private let seriesPerLength = 2
    private var currentSeries = 0
    private var currentSequence: [Int] = []
    private var isGameOver = false

    // MARK: - Temps
    private let maxTimePerSequence: TimeInterval = 10
    private var sequenceTimer: Timer?
    private var elapsedTime: TimeInterval = 0

    private var spokenWords: [String] = []
    private var listeningTask: Task<Void, Never>?


    // Estadístiques
    private var numErrors = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLabel()
        startGame()
    }

    private func setupLabel() {
        sequenceLabel.frame = view.bounds
        sequenceLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(sequenceLabel)
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

        if currentLength > maxLength {
            finishGame()
            return
        }

        if currentSeries >= seriesPerLength {
            currentLength += 1
            currentSeries = 0
        }

        generateSequence()
        showSequence()
        startListening()
        startSequenceTimer()
    }

    private func generateSequence() {
        currentSequence = (0..<currentLength).map {
            Int.random(in: 0...9)
        }
    }

    private func showSequence() {
        sequenceLabel.text = currentSequence.map { "\($0)" }.joined(separator: " ")
        elapsedTime = 0
    }

    // MARK: - Veu
    private func startListening() {
        spokenWords = []

        listeningTask = Task {
            do {
                let stream = try await voiceRecorder.startVoiceRecording()

                for try await transcription in stream {
                    print(transcription) // debug

                    spokenWords.append(transcription)

                    // Si volem aturar manualment
                    if transcription.lowercased().contains("stop listening") {
                        voiceRecorder.stopVoiceRecording()
                        break
                    }
                }

                await MainActor.run {
                    self.sequenceTimer?.invalidate()
                    let numbers = self.convertWordsToNumbers(self.spokenWords)
                    self.checkAnswer(userNumbers: numbers)
                }

            } catch {
                print("Error voice recorder: \(error)")
            }
        }
    }


    let stream = try await recorder.startVoiceRecording()

    for try await transcription in stream {
        print(transcription)

        if transcription.contains("stop listening") {
            recorder.stopVoiceRecording()
            break
        }
    }


    // MARK: - Temporitzador
    private func startSequenceTimer() {
        sequenceTimer?.invalidate()
        elapsedTime = 0

        sequenceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.elapsedTime += 0.1

            if self.elapsedTime >= self.maxTimePerSequence {
                self.sequenceTimer?.invalidate()
                self.voiceRecorder.stopVoiceRecording()
                self.listeningTask?.cancel()
                self.numErrors += 1
                self.nextRound()
            }
        }
    }

    // MARK: - Comprovació
    private func checkAnswer(userNumbers: [Int]) {
        if userNumbers == currentSequence {
            currentSeries += 1
        } else {
            numErrors += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.nextRound()
        }
    }

    // MARK: - Final del joc
    private func finishGame() {
        isGameOver = true
        sequenceTimer?.invalidate()

        let alert = UIAlertController(
            title: "Joc finalitzat",
            message: "Errors totals: \(numErrors)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Utils
        private func convertWordsToNumbers(_ words: [String]) -> [Int] {
        return words.compactMap { word in
            Int(word.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}
