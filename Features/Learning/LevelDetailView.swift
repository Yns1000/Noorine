import SwiftUI

struct LevelDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    let levelNumber: Int
    let title: String
    
    @State private var selectedLetter: ArabicLetter?
    
    var letters: [ArabicLetter] {
        ArabicLetter.letters(forLevel: levelNumber)
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    LevelDetailHeader(
                        title: title,
                        masteredCount: masteredCount,
                        totalCount: letters.count
                    )
                    .padding(.top, 10)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(letters) { letter in
                            LetterCard(
                                letter: letter,
                                isMastered: dataManager.isLetterMastered(letterId: letter.id, inLevel: levelNumber)
                            )
                            .onTapGesture {
                                selectedLetter = letter
                            }
                        }
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            Text(LocalizedStringKey("Retour"))
                    }
                    .foregroundColor(.noorGold)
                }
            }
        }
        .fullScreenCover(item: $selectedLetter) { letter in
            if let index = letters.firstIndex(where: { $0.id == letter.id }), index + 1 < letters.count {
                LetterLessonView(
                    letter: letter,
                    levelNumber: levelNumber,
                )
                .environmentObject(dataManager)
                .id(letter.id)
            } else {
                LetterLessonView(
                    letter: letter,
                    levelNumber: levelNumber,
                )
                .environmentObject(dataManager)
                .id(letter.id)
            }
        }
    }
    
    var masteredCount: Int {
        letters.filter { dataManager.isLetterMastered(letterId: $0.id, inLevel: levelNumber) }.count
    }
}

struct LevelDetailHeader: View {
    let title: String
    let masteredCount: Int
    let totalCount: Int
    
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(masteredCount) / Double(totalCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.noorText)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(LocalizedStringKey("\(masteredCount)/\(totalCount) lettres maîtrisées"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.noorSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.noorGold)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.noorSecondary.opacity(0.2))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.noorGold, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

struct LetterCard: View {
    @Environment(\.colorScheme) var colorScheme
    let letter: ArabicLetter
    let isMastered: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isMastered ? Color.noorGold.opacity(0.15) : Color.noorSecondary.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Text(letter.isolated)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(isMastered ? .noorGold : .noorText)
                
                if isMastered {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.noorGold)
                        .offset(x: 25, y: -25)
                }
            }
            
            Text(letter.transliteration)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.noorSecondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
}

#Preview {
    NavigationView {
        LevelDetailView(levelNumber: 1, title: "L'Alphabet (1-7)")
            .environmentObject(DataManager.shared)
    }
}
