import AVFoundation
import Speech

final class VoiceRecorder {

    private let audioEngine = AVAudioEngine()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ca-ES"))!
    private var sessionResults: [String] = []
    var paraules: Bool?
    let numberWords: [String: String] = [
        "un": "1",
        "dos": "2",
        "tres": "3",
        "quatre": "4",
        "cinc": "5",
        "sis": "6",
        "set": "7",
        "vuit": "8",
        "nou": "9"
    ]

    let months: [String: String] = [
        "gener": "1",
        "febrer": "2",
        "març": "3",
        "abril": "4",
        "maig": "5",
        "juny": "6",
        "juliol": "7",
        "agost": "8",
        "setembre": "9"
    ]


    // MARK: - Permissions
    func requestPermissions() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { micGranted in
                guard micGranted else {
                    print("Microphone access denied")
                    continuation.resume(returning: false)
                    return
                }

                SFSpeechRecognizer.requestAuthorization { status in
                    DispatchQueue.main.async {
                        continuation.resume(returning: status == .authorized)
                    }
                }
            }
        }
    }

    // MARK: - Start Recording
    func startVoiceRecording(paraules: Bool?) async throws {
        guard await requestPermissions() else {
            throw NSError(domain: "VoiceRecorder", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Permissions denied"])
        }

        sessionResults.removeAll()

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .spokenAudio)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let text = result.bestTranscription.formattedString
                if result.isFinal {
                    self.sessionResults.append(text)
                }
                print("Partial transcription:", text)
                self.sessionResults.append(text)
            } else if let error = error {
                print("Recognition error:", error)
                

            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    // MARK: - Stop Recording
    func stopVoiceRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        //recognitionTask?.cancel()
        //recognitionTask = nil
        print("He parat senyors")
        print("Session Results:", self.sessionResults[self.sessionResults.count - 1])
    }

    // MARK: - Get Results
    func getSessionResults() -> [String] {
        var result: [String] = []

        for raw in self.sessionResults[self.sessionResults.count - 1] {
            let token = raw.lowercased()

            if let digit = numberWords[token] {
                result.append(digit)
                continue
            }

            if let digit = months[token] {
                result.append(digit)
                continue
            }

            let digits = token.filter { $0.isNumber }
            if !digits.isEmpty {
                result.append(contentsOf: digits.map { String($0) })
            }
        }
        if result.count < 5 {
            return result
        }
        else {
            return Array(result.suffix(5))
        }
    }
}
