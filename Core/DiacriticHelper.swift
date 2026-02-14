import Foundation
import SwiftUI

struct DiacriticInfo: Hashable, Identifiable {
    let id = UUID()
    let character: String
    let name: String
    let nameAr: String
    let explanation: String
    let explanationFr: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: DiacriticInfo, rhs: DiacriticInfo) -> Bool {
        lhs.name == rhs.name
    }
}

struct DiacriticHelper {
    
    static func detectDiacritics(in text: String) -> [DiacriticInfo] {
        var results: [DiacriticInfo] = []
        
        for char in text.unicodeScalars {
            if let info = diacriticInfo(for: char) {
                if !results.contains(where: { $0.name == info.name }) {
                    results.append(info)
                }
            }
        }
        
        return results
    }
    
    static func hasDiacritics(in text: String) -> Bool {
        let diacriticScalars: Set<UInt32> = [
            0x064E, 0x064F, 0x0650, 0x0651, 0x0652,
            0x064B, 0x064C, 0x064D,
            0x0670, 0x0653
        ]
        
        return text.unicodeScalars.contains { diacriticScalars.contains($0.value) }
    }
    
    static func highlightedArabicText(text: String, fontSize: CGFloat = 22) -> some View {
        let diacriticPurple = Color(red: 0.6, green: 0.3, blue: 0.85)
        let diacriticScalars: Set<UInt32> = [
            0x064E, 0x064F, 0x0650, 0x0651, 0x0652,
            0x064B, 0x064C, 0x064D, 0x0670
        ]
        
        var attributed = AttributedString()
        
        for char in text {
            let charStr = String(char)
            let hasDiacritic = char.unicodeScalars.contains { diacriticScalars.contains($0.value) }
            
            var charAttr = AttributedString(charStr)
            charAttr.font = .system(size: fontSize, weight: .bold, design: .rounded)
            
            if hasDiacritic {
                charAttr.foregroundColor = diacriticPurple
                charAttr.underlineStyle = .single
                charAttr.underlineColor = UIColor(diacriticPurple)
            } else {
                charAttr.foregroundColor = .noorGold
            }
            
            attributed.append(charAttr)
        }
        
        return Text(attributed)
            .environment(\.layoutDirection, .rightToLeft)
    }
    
    private static func diacriticInfo(for scalar: Unicode.Scalar) -> DiacriticInfo? {
        switch scalar.value {
            
        case 0x064E:
            return DiacriticInfo(
                character: "◌َ",
                name: "Fatha",
                nameAr: "فَتْحَة",
                explanation: "Short 'a' sound - like in 'cat'",
                explanationFr: "Son 'a' court - comme dans 'chat'"
            )
        case 0x064F:
            return DiacriticInfo(
                character: "◌ُ",
                name: "Damma",
                nameAr: "ضَمَّة",
                explanation: "Short 'u' sound - like in 'put'",
                explanationFr: "Son 'ou' court - comme dans 'tout'"
            )
        case 0x0650:
            return DiacriticInfo(
                character: "◌ِ",
                name: "Kasra",
                nameAr: "كَسْرَة",
                explanation: "Short 'i' sound - like in 'bit'",
                explanationFr: "Son 'i' court - comme dans 'lit'"
            )
        case 0x0652:
            return DiacriticInfo(
                character: "◌ْ",
                name: "Sukun",
                nameAr: "سُكُون",
                explanation: "No vowel - consonant ends syllable",
                explanationFr: "Pas de voyelle - la consonne termine la syllabe"
            )
        case 0x0651:
            return DiacriticInfo(
                character: "◌ّ",
                name: "Shadda",
                nameAr: "شَدَّة",
                explanation: "Double the consonant sound",
                explanationFr: "Doubler le son de la consonne"
            )
            
        case 0x0621:
            return DiacriticInfo(
                character: "ء",
                name: "Hamza",
                nameAr: "هَمْزَة",
                explanation: "Glottal stop - brief throat pause",
                explanationFr: "Coup de glotte - pause brève dans la gorge"
            )
        case 0x0623:
            return DiacriticInfo(
                character: "أ",
                name: "Hamza on Alif",
                nameAr: "أَلِف بِهَمْزَة",
                explanation: "Glottal stop starting with 'a' sound",
                explanationFr: "Coup de glotte commençant par le son 'a'"
            )
        case 0x0625:
            return DiacriticInfo(
                character: "إ",
                name: "Hamza under Alif",
                nameAr: "هَمْزَة تَحْت الأَلِف",
                explanation: "Glottal stop starting with 'i' sound",
                explanationFr: "Coup de glotte commençant par le son 'i'"
            )
        case 0x0622:
            return DiacriticInfo(
                character: "آ",
                name: "Alif Madda",
                nameAr: "أَلِف مَدَّة",
                explanation: "Long 'aa' sound - held longer",
                explanationFr: "Son 'aa' long - tenu plus longtemps"
            )
        case 0x0624:
            return DiacriticInfo(
                character: "ؤ",
                name: "Hamza on Waw",
                nameAr: "هَمْزَة عَلَى واو",
                explanation: "Glottal stop with 'u' sound",
                explanationFr: "Coup de glotte avec le son 'ou'"
            )
        case 0x0626:
            return DiacriticInfo(
                character: "ئ",
                name: "Hamza on Ya",
                nameAr: "هَمْزَة عَلَى ياء",
                explanation: "Glottal stop with 'i' sound",
                explanationFr: "Coup de glotte avec le son 'i'"
            )
        case 0x0654, 0x0655:
            return DiacriticInfo(
                character: "ء",
                name: "Hamza",
                nameAr: "هَمْزَة",
                explanation: "Glottal stop - brief throat pause",
                explanationFr: "Coup de glotte - pause brève"
            )
            
        case 0x064B:
            return DiacriticInfo(
                character: "◌ً",
                name: "Tanwin Fath",
                nameAr: "تَنْوِين فَتْح",
                explanation: "Adds '-an' sound at the end",
                explanationFr: "Ajoute le son '-an' à la fin"
            )
        case 0x064C:
            return DiacriticInfo(
                character: "◌ٌ",
                name: "Tanwin Damm",
                nameAr: "تَنْوِين ضَمّ",
                explanation: "Adds '-un' sound at the end",
                explanationFr: "Ajoute le son '-oun' à la fin"
            )
        case 0x064D:
            return DiacriticInfo(
                character: "◌ٍ",
                name: "Tanwin Kasr",
                nameAr: "تَنْوِين كَسْر",
                explanation: "Adds '-in' sound at the end",
                explanationFr: "Ajoute le son '-in' à la fin"
            )
            
        case 0x0670:
            return DiacriticInfo(
                character: "◌ٰ",
                name: "Alif Khanjariyya",
                nameAr: "أَلِف خَنْجَرِيَّة",
                explanation: "Small alif - represents long 'a'",
                explanationFr: "Petit alif - représente un 'a' long"
            )
            
        default:
            return nil
        }
    }
}

struct LetterWithDiacritics: Identifiable, Equatable {
    let id = UUID()
    let letterId: Int
    let baseCharacter: String
    let diacritics: String
    let fullCharacter: String
    
    var displayText: String {
        fullCharacter
    }
    
    static func == (lhs: LetterWithDiacritics, rhs: LetterWithDiacritics) -> Bool {
        lhs.id == rhs.id
    }
}

extension DiacriticHelper {
    static func extractLettersWithDiacritics(from arabicText: String, letterIds: [Int]) -> [LetterWithDiacritics] {
        let diacriticScalars: Set<UInt32> = [
            0x064E, 0x064F, 0x0650, 0x0651, 0x0652, 
            0x064B, 0x064C, 0x064D,
            0x0670, 0x0653
        ]
        
        var results: [LetterWithDiacritics] = []
        var letterIndex = 0
        var currentBase = ""
        var currentDiacritics = ""
        
        for scalar in arabicText.unicodeScalars {
            if diacriticScalars.contains(scalar.value) {
                currentDiacritics += String(scalar)
            } else if scalar.value >= 0x0600 && scalar.value <= 0x06FF {
                if !currentBase.isEmpty && letterIndex <= letterIds.count {
                    let letterId = letterIndex < letterIds.count ? letterIds[letterIndex] : 0
                    results.append(LetterWithDiacritics(
                        letterId: letterId,
                        baseCharacter: currentBase,
                        diacritics: currentDiacritics,
                        fullCharacter: currentBase + currentDiacritics
                    ))
                    letterIndex += 1
                }
                currentBase = String(scalar)
                currentDiacritics = ""
            }
        }
        
        if !currentBase.isEmpty && letterIndex < letterIds.count {
            results.append(LetterWithDiacritics(
                letterId: letterIds[letterIndex],
                baseCharacter: currentBase,
                diacritics: currentDiacritics,
                fullCharacter: currentBase + currentDiacritics
            ))
        }
        
        return results
    }
}

struct DiacriticBreakdownView: View {
    let arabicText: String
    let showMascot: Bool
    let isCompact: Bool
    
    @EnvironmentObject var languageManager: LanguageManager
    
    init(arabicText: String, showMascot: Bool = true, isCompact: Bool = false) {
        self.arabicText = arabicText
        self.showMascot = showMascot
        self.isCompact = isCompact
    }
    
    private var diacritics: [DiacriticInfo] {
        DiacriticHelper.detectDiacritics(in: arabicText)
    }
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    var body: some View {
        if !diacritics.isEmpty {
            if isCompact {
                compactView
            } else {
                fullView
            }
        }
    }
    
    private var fullView: some View {
        HStack(alignment: .center, spacing: 16) {
            if showMascot {
                EmotionalMascot(mood: .happy, size: 70, showAura: false)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(isEnglish ? "Let me explain this word" : "Laisse-moi t'expliquer ce mot")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                ForEach(diacritics) { info in
                    diacriticRow(info: info)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
    
    private var compactView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color.noorGold)
                Text(isEnglish ? "Special marks" : "Signes spéciaux")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            
            FlowLayout(spacing: 8) {
                ForEach(diacritics) { info in
                    compactChip(info: info)
                }
            }
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
    
    private let diacriticPurple = Color(red: 0.6, green: 0.3, blue: 0.85)
    
    private func diacriticRow(info: DiacriticInfo) -> some View {
        HStack(spacing: 10) {
            Text(info.character)
                .font(.system(size: 22))
                .frame(width: 32, height: 32)
                .background(diacriticPurple.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text(info.name)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(diacriticPurple)
                    Text(info.nameAr)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(isEnglish ? info.explanation : info.explanationFr)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func compactChip(info: DiacriticInfo) -> some View {
        HStack(spacing: 6) {
            Text(info.character)
                .font(.system(size: 16))
            Text(info.name)
                .font(.caption2.weight(.medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(diacriticPurple.opacity(0.1))
        .foregroundStyle(diacriticPurple)
        .cornerRadius(20)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}

#Preview {
    VStack(spacing: 20) {
        DiacriticBreakdownView(arabicText: "أَبْ")
        DiacriticBreakdownView(arabicText: "أُمّ", isCompact: true)
    }
    .padding()
    .environmentObject(LanguageManager())
}
