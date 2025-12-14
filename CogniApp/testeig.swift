import AVFoundation
import Speech

final class VoiceRecorder {

    private let audioEngine = AVAudioEngine()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ca-ES"))!
    private var sessionResults: [String] = []
    private var paraules: Bool = false
    private var transcriptionContinuation: AsyncThrowingStream<String, Error>.Continuation?

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
    func startVoiceRecording() async throws
    -> AsyncThrowingStream<String, Error> {

        guard await requestPermissions() else {
            throw NSError(
                domain: "VoiceRecorder",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Permissions denied"]
            )
        }

        return AsyncThrowingStream { continuation in
            self.transcriptionContinuation = continuation

            continuation.onTermination = { [weak self] _ in
                self?.recognitionTask?.cancel()
                self?.recognitionTask = nil
            }

            do {
                sessionResults.removeAll()

                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playAndRecord, mode: .spokenAudio)
                try audioSession.setActive(true)

                recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                recognitionRequest?.shouldReportPartialResults = true

                recognitionTask = speechRecognizer.recognitionTask(
                    with: recognitionRequest!
                ) { [weak self] result, error in
                    guard let self = self else { return }

                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }

                    guard let result = result else { return }

                    let text = result.bestTranscription.formattedString
                    continuation.yield(text)

                    if result.isFinal {
                        self.sessionResults.append(text)
                    }
                }

            } catch {
                continuation.finish(throwing: error)
            }
        }
    }


    // MARK: - Stop Recording
    func stopVoiceRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()

        recognitionTask?.cancel()
        recognitionTask = nil

        transcriptionContinuation?.finish()
        transcriptionContinuation = nil

        print("He parat senyors")
    }


    // MARK: - Get Results
    func getSessionResults() -> [String] {
        return sessionResults
    }
}
