import AVFoundation
import Speech

final class VoiceRecorder {

    private let audioEngine = AVAudioEngine()
    private var outputContinuation: AsyncStream<AVAudioPCMBuffer>.Continuation?
    private var buffers: [AVAudioPCMBuffer] = []
    private var sessionResults: [String] = []
    private let transcriber: SpeechTranscriber

    init() async throws {
        let locale = Locale(identifier: "ca")
        transcriber = SpeechTranscriber(locale: locale, preset: .offlineTranscription)
        try await transcriber.setUpTranscriber()
    }

    func startVoiceRecording() async throws -> AsyncStream<AVAudioPCMBuffer> {
        guard await requestPermissions() else {
            throw NSError(domain: "VoiceRecorder", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permissions denied"])
        }
        buffers.removeAll()
        sessionResults.removeAll()
        outputContinuation?.finish()
        outputContinuation = nil
        try setUpAudioSession()
        let inputNode = audioEngine.inputNode
        let format = inputNode.inputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, _ in
            guard let self = self else { return }
            self.buffers.append(buffer.copy() as! AVAudioPCMBuffer)
            self.outputContinuation?.yield(buffer)
            Task {
                try await self.transcriber.streamAudioToTranscriber(buffer)
            }
        }

        audioEngine.prepare()
        try audioEngine.start()
        return AsyncStream<AVAudioPCMBuffer>(bufferingPolicy: .unbounded) { continuation in
            self.outputContinuation = continuation
        }
    }

    func stopVoiceRecording() async throws -> [String] {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        outputContinuation?.finish()
        outputContinuation = nil
        sessionResults.removeAll()
        for try await result in transcriber.results {
            sessionResults.append(String(result.text.characters))
        }
        return sessionResults
    }

    private func setUpAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .spokenAudio)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

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
                        switch status {
                        case .authorized:
                            continuation.resume(returning: true)
                        default:
                            print("Speech recognition not authorized")
                            continuation.resume(returning: false)
                        }
                    }
                }
            }
        }
    }
}
