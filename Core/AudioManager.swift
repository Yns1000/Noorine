import Foundation
import AVFoundation
import AudioToolbox
import SwiftUI
import Combine
import CryptoKit

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    private let cacheSynthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    private let cacheQueue = DispatchQueue(label: "AudioManager.TTSCache")
    private var cacheInFlight: Set<String> = []
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
    
    enum SpeechStyle {
        case letter
        case word
        case phraseSlow
        case phraseNormal
    }
    
    private struct SpeechProfile {
        let rate: Float
        let pitch: Float
        let volume: Float
        let preDelay: TimeInterval
        let postDelay: TimeInterval
    }
    
    func playLetter(_ text: String) {
        playText(text, style: .letter, useCache: true)
    }
    
    func playText(_ text: String, style: SpeechStyle = .word, useCache: Bool = true) {
        stopAllAudio()
        
        let voice = selectArabicVoice()
        let profile = speechProfile(for: style)
        let cacheKey = makeCacheKey(text: text, profile: profile, voice: voice)
        
        if useCache, let cachedURL = cacheFileURL(for: cacheKey),
           FileManager.default.fileExists(atPath: cachedURL.path) {
            playAudioFile(cachedURL)
            return
        }
        
        let utterance = makeUtterance(text: text, profile: profile, voice: voice)
        synthesizer.speak(utterance)
        
        if useCache {
            cacheUtterance(text: text, profile: profile, voice: voice, cacheKey: cacheKey)
        }
    }
    
    func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    func playSound(named soundName: String) {
        if let audioURL = bundledAudioURL(for: soundName) {
            playAudioFile(audioURL)
            return
        }
        
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
            playText(textToSpeak, style: .letter, useCache: true)
            return
        }
        
        if let phrase = CourseContent.phrases.first(where: { $0.audioName == soundName }) {
            playText(phrase.arabic, style: .phraseNormal, useCache: true)
            return
        }
        
        if containsArabicCharacters(soundName) {
            playText(soundName, style: .phraseNormal, useCache: true)
            return
        }
        
        print("Audio/TTS missing for: \(soundName)")
    }
    
    private func speechProfile(for style: SpeechStyle) -> SpeechProfile {
        switch style {
        case .letter:
            return SpeechProfile(rate: 0.45, pitch: 0.95, volume: 1.0, preDelay: 0.0, postDelay: 0.05)
        case .word:
            return SpeechProfile(rate: 0.48, pitch: 1.0, volume: 1.0, preDelay: 0.0, postDelay: 0.05)
        case .phraseSlow:
            return SpeechProfile(rate: 0.42, pitch: 1.0, volume: 1.0, preDelay: 0.0, postDelay: 0.08)
        case .phraseNormal:
            return SpeechProfile(rate: 0.53, pitch: 1.0, volume: 1.0, preDelay: 0.0, postDelay: 0.06)
        }
    }
    
    private func makeUtterance(text: String, profile: SpeechProfile, voice: AVSpeechSynthesisVoice?) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = profile.rate
        utterance.volume = profile.volume
        utterance.pitchMultiplier = profile.pitch
        utterance.preUtteranceDelay = profile.preDelay
        utterance.postUtteranceDelay = profile.postDelay
        return utterance
    }
    
    private func selectArabicVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("ar") }
        
        if let maged = voices.first(where: { $0.name.contains("Maged") }) {
            return maged
        }
        if let premium = voices.first(where: { $0.quality == .premium }) {
            return premium
        }
        if let enhanced = voices.first(where: { $0.quality == .enhanced }) {
            return enhanced
        }
        if let preferred = voices.first(where: { $0.language == "ar-SA" }) {
            return preferred
        }
        
        return AVSpeechSynthesisVoice(language: "ar-SA")
    }
    
    private func stopAllAudio() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
        }
    }
    
    private func bundledAudioURL(for soundName: String) -> URL? {
        let extensions = ["m4a", "mp3", "wav", "caf"]
        for ext in extensions {
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext) {
                return url
            }
        }
        return nil
    }
    
    private func playAudioFile(_ url: URL) {
        stopAllAudio()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Audio playback error: \(error)")
        }
    }
    
    private func cacheDirectoryURL() -> URL? {
        guard let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = base.appendingPathComponent("noorine-tts", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    private func cacheFileURL(for key: String) -> URL? {
        guard let dir = cacheDirectoryURL() else { return nil }
        return dir.appendingPathComponent("\(key).caf")
    }
    
    private func makeCacheKey(text: String, profile: SpeechProfile, voice: AVSpeechSynthesisVoice?) -> String {
        let voiceId = voice?.identifier ?? "default"
        let raw = "\(voiceId)|\(profile.rate)|\(profile.pitch)|\(profile.volume)|\(text)"
        let hash = SHA256.hash(data: Data(raw.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    private func cacheUtterance(text: String, profile: SpeechProfile, voice: AVSpeechSynthesisVoice?, cacheKey: String) {
        guard let url = cacheFileURL(for: cacheKey) else { return }
        
        cacheQueue.async {
            if self.cacheInFlight.contains(cacheKey) {
                return
            }
            self.cacheInFlight.insert(cacheKey)
            
            let utterance = self.makeUtterance(text: text, profile: profile, voice: voice)
            var audioFile: AVAudioFile?
            
            self.cacheSynthesizer.write(utterance) { buffer in
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer else { return }
                
                if pcmBuffer.frameLength == 0 {
                    self.cacheQueue.async {
                        self.cacheInFlight.remove(cacheKey)
                    }
                    return
                }
                
                if audioFile == nil {
                    audioFile = try? AVAudioFile(forWriting: url, settings: pcmBuffer.format.settings)
                }
                
                do {
                    try audioFile?.write(from: pcmBuffer)
                } catch {
                    // Ignore cache write errors.
                }
            }
        }
    }
    
    private func containsArabicCharacters(_ text: String) -> Bool {
        return text.unicodeScalars.contains { scalar in
            switch scalar.value {
            case 0x0600...0x06FF, 0x0750...0x077F, 0x08A0...0x08FF, 0xFB50...0xFDFF, 0xFE70...0xFEFF:
                return true
            default:
                return false
            }
        }
    }
}
