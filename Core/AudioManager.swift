import Foundation
import AVFoundation
import AudioToolbox
import SwiftUI
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var isWarmedUp = false
    
    private init() {
        configureAudioSession()
    }
    
    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetoothA2DP, .duckOthers]
            )
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio config error: \(error)")
        }
    }
    
    func warmup() {
        guard !isWarmedUp else { return }
        isWarmedUp = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let utterance = AVSpeechUtterance(string: " ")
            utterance.volume = 0.001
            self.synthesizer.speak(utterance)
        }
    }
    
    func playLetter(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "ar-SA" }
        if let maged = voices.first(where: { $0.name.contains("Maged") }) {
            utterance.voice = maged
        } else if let enhanced = voices.first(where: { $0.quality == .enhanced || $0.quality == .premium }) {
            utterance.voice = enhanced
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "ar-SA")
        }
        
        utterance.rate = 0.45
        utterance.volume = 1.0
        utterance.pitchMultiplier = 0.95
        
        synthesizer.speak(utterance)
    }
    
    func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    func playSound(named soundName: String) {
    }
}
