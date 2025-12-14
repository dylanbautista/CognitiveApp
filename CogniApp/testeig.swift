import AVFoundation
import Speech

final class VoiceRecorder {

    private let audioEngine = AVAudioEngine()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ca-ES"))!
    private var sessionResults: [String] = []

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
    func startVoiceRecording() async throws {
        guard await requestPermissions() else {
            throw NSError(domain: "VoiceRecorder", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Permissions denied"])
        }

        // Clear previous session results
        sessionResults.removeAll()

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .spokenAudio)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Prepare recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        // Cancel previous task if running
        recognitionTask?.cancel()
        recognitionTask = nil

        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let text = result.bestTranscription.formattedString
                if result.isFinal {
                    self.sessionResults.append(text)
                }
                print("Partial transcription:", text)
            } else if let error = error {
                print("Recognition error:", error)
            }
        }

        // Configure audio engine
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
        recognitionTask?.cancel()
        recognitionTask = nil
        print("He parat guarres")
    }

    // MARK: - Get Results
    func getSessionResults() -> [String] {
        return sessionResults
    }
}
