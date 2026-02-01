import SwiftUI
import Combine
import Speech
import AVFoundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case french = "fr"
    case english = "en"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .french: return "Français"
        case .english: return "English"
        }
    }
    
    var courseLabel: String {
        switch self {
        case .french: return "Français → Arabe"
        case .english: return "English → Arabic"
        }
    }
}

class LanguageManager: ObservableObject {
    @AppStorage("user_language") private var storedLanguage: String?
    
    @Published var currentLanguage: AppLanguage
    
    init() {
        if let stored = UserDefaults.standard.string(forKey: "user_language"),
           let lang = AppLanguage(rawValue: stored) {
            self.currentLanguage = lang
        } else {
            let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            if systemLang.contains("fr") {
                self.currentLanguage = .french
            } else {
                self.currentLanguage = .english
            }
        }
    }
    
    func setLanguage(_ lang: AppLanguage) {
        withAnimation {
            currentLanguage = lang
            storedLanguage = lang.rawValue
            UserDefaults.standard.set(lang.rawValue, forKey: "user_language")
        }
    }
    
    func localizedString(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

class SpeechManager: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var audioLevel: Float = 0.0
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published var error: String?
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                self?.authorizationStatus = authStatus
            }
        }
    }
    
    func startRecording() throws {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            var isFinal = false
            
            if let result = result {
                DispatchQueue.main.async {
                    self?.recognizedText = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self?.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
            self?.recognitionRequest?.append(buffer)
            
            let channelData = buffer.floatChannelData?[0]
            let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map{ channelData?[ $0 ] ?? 0 }
            
            let rms = sqrt(channelDataValueArray.map{ $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
            let avgPower = 20 * log10(rms)
            
            let meterLevel = self?.scaledPower(power: avgPower) ?? 0.0
            
            DispatchQueue.main.async {
                self?.audioLevel = meterLevel
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        DispatchQueue.main.async {
            self.isRecording = true
            self.recognizedText = ""
            self.error = nil
        }
    }
    
    func stopRecording() {
        recognitionRequest?.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.finish()
        recognitionTask = nil
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to reset audio session: \(error)")
        }
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.audioLevel = 0.0
        }
    }
    
    private func scaledPower(power: Float) -> Float {
        guard power.isFinite else { return 0.0 }
        let minDb: Float = -60.0
        
        if power < minDb {
            return 0.0
        } else if power >= 1.0 {
            return 1.0
        } else {
            return (abs(minDb) - abs(power)) / abs(minDb)
        }
    }
}
