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

    private lazy var arabicToAudioName: [String: String] = {
        var map: [String: String] = [:]

        let letterAudioMap: [String: String] = [
            "ا": "alif",  "أَلِف": "alif",
            "ب": "b",     "بَاء": "b",
            "ت": "t",     "تَاء": "t",
            "ث": "th",    "ثَاء": "th",
            "ج": "jm",    "جِيم": "jm",
            "خ": "kh",    "خَاء": "kh",
            "د": "dl",    "دَال": "dl",
            "ذ": "dhl",   "ذَال": "dhl",
            "ر": "r",     "رَاء": "r",
            "ز": "zy",    "زَاي": "zy",
            "س": "sn",    "سِين": "sn",
            "ش": "shn",   "شِين": "shn",
            "ض": "d",     "ضَاد": "d",
            "ح": "haa",   "حَاء": "haa",
            "ص": "saad",  "صَاد": "saad",
            "ط": "taa_emp","طَاء": "taa_emp",
            "ظ": "dhaa_emp","ظَاء": "dhaa_emp",
            "ع": "ayn",   "عَين": "ayn",
            "غ": "ghayn", "غَين": "ghayn",
            "ف": "f",     "فَاء": "f",
            "ق": "qf",    "قَاف": "qf",
            "ك": "kf",    "كَاف": "kf",
            "ل": "lm",    "لَام": "lm",
            "م": "mm",    "مِيم": "mm",
            "ن": "nn",    "نُون": "nn",
            "ه": "h",     "هَاء": "h",
            "و": "ww",    "وَاو": "ww",
            "ي": "y",     "يَاء": "y",
            "ة": "tmarba",
            "ء": "hamza", "هَمْزَة": "hamza",
        ]
        for (key, value) in letterAudioMap {
            map[key] = value
        }

        for word in CourseContent.words {
            let name = word.transliteration
                .lowercased()
                .replacingOccurrences(of: "[^a-z0-9_]", with: "", options: .regularExpression)
            if !name.isEmpty {
                map[word.arabic] = name
            }
        }

        for phrase in CourseContent.phrases {
            if let audioName = phrase.audioName, !audioName.isEmpty {
                map[phrase.arabic] = audioName
            }
        }

        for vowel in CourseContent.vowels {
            for example in vowel.examples {
                if !example.audioName.isEmpty {
                    map[example.combination] = example.audioName
                }
            }
        }

        for card in FlashcardManager.shared.allCards {
            let name = card.transliteration
                .lowercased()
                .replacingOccurrences(of: "[^a-z0-9_]", with: "", options: .regularExpression)
            if !name.isEmpty {
                map[card.arabic] = name
            }
        }

        let dialogueAudio: [String: String] = [
            "وَعَلَيْكُمُ السَّلَام": "dialogue_wa_alaykum",
            "قَهْوَة مِن فَضْلِك": "dialogue_qahwa",
            "تَفَضَّل": "dialogue_tafaddal",
            "اِسْمِي لُورِين": "dialogue_ismi_laurine",
            "مِن أَيْنَ أَنْتِ؟": "dialogue_min_ayna",
            "أَنَا مِن فَرَنْسَا": "dialogue_ana_min_faransa",
            "أَنَا كَذَلِك": "dialogue_ana_kadhalik",
            "مَرْحَبًا! أَهْلًا وَسَهْلًا": "dialogue_marhaban_ahlan",
            "بِكَم هٰذَا؟": "dialogue_bikam",
            "خَمْسَة دَرَاهِم": "dialogue_khamsa_darahim",
            "حَسَنًا، أُرِيدُهُ": "dialogue_hasanan_uriduhu",
            "شُكْرًا! مَعَ السَّلَامَة": "dialogue_shukran_maa_salama",
        ]
        for (key, value) in dialogueAudio { map[key] = value }

        let solarLunarAudio: [String: String] = [
            "الشَّمْس": "ash_shams",
            "القَمَر": "al_qamar",
        ]
        for (key, value) in solarLunarAudio { map[key] = value }

        let tanwinAudio: [String: String] = [
            "تَنْوِين فَتْح": "tanwin_fatha",
            "تَنْوِين كَسْر": "tanwin_kasra",
            "تَنْوِين ضَمّ": "tanwin_damma",
        ]
        for (key, value) in tanwinAudio { map[key] = value }

        return map
    }()
    
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
            utterance.voice = self.selectArabicVoice()
            self.synthesizer.speak(utterance)
        }
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
            let commonSounds = ["بَ", "تَ", "سَ", "مَ", "نَ"]
            for sound in commonSounds {
                self.playText(sound, style: .letter, useCache: true)
                self.stopAllAudio()
            }
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

        if let name = generatedAudioName(for: text),
           let url = bundledAudioURL(for: name) {
            playAudioFile(url)
            return
        }

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

    private func generatedAudioName(for arabicText: String) -> String? {
        let trimmed = arabicText.trimmingCharacters(in: .whitespacesAndNewlines)
        return arabicToAudioName[trimmed]
    }
    
    func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    func playSound(named soundName: String) {
        if let audioURL = bundledAudioURL(for: soundName) {
            playAudioFile(audioURL)
            return
        }
        
        let letterToArabic: [String: String] = [
            "alif": "ا", "ba": "ب", "ta": "ت", "tha": "ث",
            "jim": "ج", "ha": "ح", "kha": "خ", "dal": "د", "dhal": "ذ",
            "ra": "ر", "zay": "ز", "sin": "س", "shin": "ش", "sad": "ص",
            "dad": "ض", "ta_emphatic": "ط", "za_emphatic": "ظ", "ayn": "ع", "ghayn": "غ",
            "fa": "ف", "qaf": "ق", "kaf": "ك", "lam": "ل", "mim": "م",
            "nun": "ن", "ha_round": "ه", "waw": "و", "ya": "ي"
        ]
        
        let ttsMap: [String: String] = [
            "fatha_sound": "فَتْحَة",
            "kasra_sound": "كَسْرَة",
            "damma_sound": "ضَمَّة",
            "sukun_sound": "سُكُون",
            "shadda_sound": "شَدَّة",
            "tanwin_fatha_sound": "تَنْوِين فَتْح",
            "tanwin_kasra_sound": "تَنْوِين كَسْر",
            "tanwin_damma_sound": "تَنْوِين ضَمّ",
            "tanwinFatha_sound": "تَنْوِين فَتْح",
            
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
            "ya_fatha": "يَ", "ya_kasra": "يِ", "ya_damma": "يُ",
            
            "ba_sukun": "أَبْ", "ta_sukun": "أَتْ", "tha_sukun": "أَثْ",
            "jim_sukun": "أَجْ", "ha_sukun": "أَحْ", "kha_sukun": "أَخْ",
            "dal_sukun": "أَدْ", "dhal_sukun": "أَذْ",
            "ra_sukun": "أَرْ", "zay_sukun": "أَزْ",
            "sin_sukun": "أَسْ", "shin_sukun": "أَشْ", "sad_sukun": "أَصْ",
            "dad_sukun": "أَضْ", "ta_emphatic_sukun": "أَطْ", "za_emphatic_sukun": "أَظْ",
            "ayn_sukun": "أَعْ", "ghayn_sukun": "أَغْ",
            "fa_sukun": "أَفْ", "qaf_sukun": "أَقْ", "kaf_sukun": "أَكْ",
            "lam_sukun": "أَلْ", "mim_sukun": "أَمْ", "nun_sukun": "أَنْ",
            "ha_round_sukun": "أَهْ", "waw_sukun": "أَوْ", "ya_sukun": "أَيْ",
            
            "ba_shadda": "بَّ", "ta_shadda": "تَّ", "tha_shadda": "ثَّ",
            "jim_shadda": "جَّ", "ha_shadda": "حَّ", "kha_shadda": "خَّ",
            "dal_shadda": "دَّ", "dhal_shadda": "ذَّ",
            "ra_shadda": "رَّ", "zay_shadda": "زَّ",
            "sin_shadda": "سَّ", "shin_shadda": "شَّ", "sad_shadda": "صَّ",
            "dad_shadda": "ضَّ", "ta_emphatic_shadda": "طَّ", "za_emphatic_shadda": "ظَّ",
            "ayn_shadda": "عَّ", "ghayn_shadda": "غَّ",
            "fa_shadda": "فَّ", "qaf_shadda": "قَّ", "kaf_shadda": "كَّ",
            "lam_shadda": "لَّ", "mim_shadda": "مَّ", "nun_shadda": "نَّ",
            "ha_round_shadda": "هَّ", "waw_shadda": "وَّ", "ya_shadda": "يَّ",
            
            "ba_tanwin_fatha": "بًا", "ta_tanwin_fatha": "تًا", "tha_tanwin_fatha": "ثًا",
            "jim_tanwin_fatha": "جًا", "ha_tanwin_fatha": "حًا", "kha_tanwin_fatha": "خًا",
            "dal_tanwin_fatha": "دًا", "dhal_tanwin_fatha": "ذًا",
            "ra_tanwin_fatha": "رًا", "zay_tanwin_fatha": "زًا",
            "sin_tanwin_fatha": "سًا", "shin_tanwin_fatha": "شًا", "sad_tanwin_fatha": "صًا",
            "dad_tanwin_fatha": "ضًا", "ta_emphatic_tanwin_fatha": "طًا", "za_emphatic_tanwin_fatha": "ظًا",
            "ayn_tanwin_fatha": "عًا", "ghayn_tanwin_fatha": "غًا",
            "fa_tanwin_fatha": "فًا", "qaf_tanwin_fatha": "قًا", "kaf_tanwin_fatha": "كًا",
            "lam_tanwin_fatha": "لًا", "mim_tanwin_fatha": "مًا", "nun_tanwin_fatha": "نًا",
            "ha_round_tanwin_fatha": "هًا", "waw_tanwin_fatha": "وًا", "ya_tanwin_fatha": "يًا",
            "ba_tanwinFatha": "بًا", "ta_tanwinFatha": "تًا", "tha_tanwinFatha": "ثًا",
            "jim_tanwinFatha": "جًا", "ha_tanwinFatha": "حًا", "kha_tanwinFatha": "خًا",
            "dal_tanwinFatha": "دًا", "dhal_tanwinFatha": "ذًا",
            "ra_tanwinFatha": "رًا", "zay_tanwinFatha": "زًا",
            "sin_tanwinFatha": "سًا", "shin_tanwinFatha": "شًا", "sad_tanwinFatha": "صًا",
            "dad_tanwinFatha": "ضًا", "ta_emphatic_tanwinFatha": "طًا", "za_emphatic_tanwinFatha": "ظًا",
            "ayn_tanwinFatha": "عًا", "ghayn_tanwinFatha": "غًا",
            "fa_tanwinFatha": "فًا", "qaf_tanwinFatha": "قًا", "kaf_tanwinFatha": "كًا",
            "lam_tanwinFatha": "لًا", "mim_tanwinFatha": "مًا", "nun_tanwinFatha": "نًا",
            "ha_round_tanwinFatha": "هًا", "waw_tanwinFatha": "وًا", "ya_tanwinFatha": "يًا"
        ]
        
        if let textToSpeak = ttsMap[soundName] {
            playText(textToSpeak, style: .letter, useCache: true)
            return
        }
        
        if soundName.hasPrefix("word_") {
            let wordName = String(soundName.dropFirst(5))
            if let word = CourseContent.words.first(where: { 
                $0.transliteration.lowercased() == wordName.lowercased() 
            }) {
                playText(word.arabic, style: .word, useCache: true)
                return
            }
        }
        
        if let phrase = CourseContent.phrases.first(where: { $0.audioName == soundName }) {
            playText(phrase.arabic, style: .phraseNormal, useCache: true)
            return
        }
        
        if let word = CourseContent.words.first(where: { 
            $0.transliteration.lowercased() == soundName.lowercased() 
        }) {
            playText(word.arabic, style: .word, useCache: true)
            return
        }
        
        if containsArabicCharacters(soundName) {
            playText(soundName, style: .phraseNormal, useCache: true)
            return
        }
        
        let parts = soundName.split(separator: "_", maxSplits: 1).map(String.init)
        if parts.count == 2, let consonant = letterToArabic[parts[0]] {
            let vowelType = parts[1]
            let arabicText: String
            switch vowelType {
            case "fatha": arabicText = consonant + "َ"
            case "kasra": arabicText = consonant + "ِ"
            case "damma": arabicText = consonant + "ُ"
            case "sukun": arabicText = "أَ" + consonant + "ْ"
            case "shadda": arabicText = consonant + "َّ"
            case "tanwinFatha", "tanwin_fatha": arabicText = consonant + "ًا"
            case "tanwinKasra", "tanwin_kasra": arabicText = consonant + "ٍ"
            case "tanwinDamma", "tanwin_damma": arabicText = consonant + "ٌ"
            default: arabicText = consonant
            }
            playText(arabicText, style: .letter, useCache: true)
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
