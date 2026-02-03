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
        let ttsMap: [String: String] = [
            "fatha_sound": "فَتْحَة",
            "kasra_sound": "كَسْرَة",
            "damma_sound": "ضَمَّة",
            
            "alif_fatha": "أَ", "alif_kasra": "إِ", "alif_damma": "أُ",
            "ba_fatha": "بَ", "ba_kasra": "بِ", "ba_damma": "بُ",
            "ta_fatha": "تَ", "ta_kasra": "تِ", "ta_damma": "تُ",
            "tha_fatha": "ثَ", "tha_kasra": "ثِ", "tha_damma": "ثُ",
            
            "jim_fatha": "جَ", "jim_kasra": "جِ", "jim_damma": "جُ",
            "ha_fatha": "حَ", "ha_kasra": "حِ", "ha_damma": "حُ",
            "kha_fatha": "خَ", "kha_kasra": "خِ", "kha_damma": "خُ",
            "dal_fatha": "دَ", "dal_kasra": "دِ", "dal_damma": "دُ",
            "dhal_fatha": "ذَ", "dhal_kasra": "ذِ", "dhal_damma": "ذُ",
            
            "ra_fatha": "رَ", "ra_kasra": "رِ", "ra_damma": "رُ",
            "zay_fatha": "زَ", "zay_kasra": "زِ", "zay_damma": "زُ",
            "sin_fatha": "سَ", "sin_kasra": "سِ", "sin_damma": "سُ",
            "shin_fatha": "شَ", "shin_kasra": "شِ", "shin_damma": "شُ",
            "sad_fatha": "صَ", "sad_kasra": "صِ", "sad_damma": "صُ",
            
            "dad_fatha": "ضَ", "dad_kasra": "ضِ", "dad_damma": "ضُ",
            "ta_emphatic_fatha": "طَ", "ta_emphatic_kasra": "طِ", "ta_emphatic_damma": "طُ",
            "za_emphatic_fatha": "ظَ", "za_emphatic_kasra": "ظِ", "za_emphatic_damma": "ظُ",
            "ayn_fatha": "عَ", "ayn_kasra": "عِ", "ayn_damma": "عُ",
            "ghayn_fatha": "غَ", "ghayn_kasra": "غِ", "ghayn_damma": "غُ",
            
            "fa_fatha": "فَ", "fa_kasra": "فِ", "fa_damma": "فُ",
            "qaf_fatha": "قَ", "qaf_kasra": "قِ", "qaf_damma": "قُ",
            "kaf_fatha": "كَ", "kaf_kasra": "كِ", "kaf_damma": "كُ",
            "lam_fatha": "لَ", "lam_kasra": "لِ", "lam_damma": "لُ",
            "mim_fatha": "مَ", "mim_kasra": "مِ", "mim_damma": "مُ",
            "nun_fatha": "نَ", "nun_kasra": "نِ", "nun_damma": "نُ",
            "ha_round_fatha": "هَ", "ha_round_kasra": "هِ", "ha_round_damma": "هُ",
            "waw_fatha": "وَ", "waw_kasra": "وِ", "waw_damma": "وُ",
            "ya_fatha": "يَ", "ya_kasra": "يِ", "ya_damma": "يُ"
        ]
        
        if let textToSpeak = ttsMap[soundName] {
            playLetter(textToSpeak)
        } else {
            print("Audio/TTS missing for: \(soundName)")
        }
    }
}
