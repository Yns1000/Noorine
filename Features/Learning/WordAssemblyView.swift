import SwiftUI

struct WordAssemblyView: View {
    let levelNumber: Int
    let onCompletion: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var words: [ArabicWord] = []
    @State private var currentWordIndex = 0
    
    @State private var scrambledLetters: [ArabicLetter] = []
    @State private var placedLetters: [ArabicLetter?] = []
    @State private var isComplete = false
    @State private var showSuccess = false
    
    @State private var draggedLetter: ArabicLetter?
    
    var currentWord: ArabicWord? {
        if words.indices.contains(currentWordIndex) {
            return words[currentWordIndex]
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            if let word = currentWord {
                VStack(spacing: 30) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.noorSecondary)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text("Word \(currentWordIndex + 1)/\(words.count)")
                            .font(.headline)
                            .foregroundColor(.noorSecondary)
                    }
                    .padding()
                    
                    VStack(spacing: 8) {
                        if showSuccess {
                            Text(word.arabic)
                                .font(.system(size: 80))
                                .foregroundColor(.noorGold)
                                .transition(.scale)
                        } else {
                            Text(word.translation)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.noorText)
                            
                            Text(word.transliteration)
                                .font(.title3)
                                .foregroundColor(.noorSecondary)
                        }
                    }
                    .frame(height: 120)
                    .animation(.spring(), value: showSuccess)
                    
                    HStack(spacing: 12) {
                        ForEach(0..<word.componentLetterIds.count, id: \.self) { index in
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .frame(width: 70, height: 90)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.noorSecondary.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    )
                                
                                if let placed = placedLetters[safe: index], let letter = placed {
                                    Text(letter.isolated)
                                        .font(.system(size: 40))
                                        .foregroundColor(.noorText)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .dropDestination(for: String.self) { items, location in
                                handleDrop(items: items, at: index)
                            } isTargeted: { isTargeted in
                            }
                        }
                    }
                    .padding()
                    
                    VStack {
                        Text("Assemble the word")
                            .font(.caption)
                            .foregroundColor(.noorSecondary)
                        
                        HStack(spacing: 20) {
                            ForEach(scrambledLetters) { letter in
                                LetterChip(letter: letter)
                                    .draggable(String(letter.id))
                                    .opacity(isLetterUsed(letter) ? 0.3 : 1.0)
                            }
                        }
                        .animation(.spring(), value: scrambledLetters)
                        .padding()
                    }
                    
                    Spacer()
                    
                    if showSuccess {
                        Button(action: nextWord) {
                            Text(currentWordIndex < words.count - 1 ? "Next Word" : "Finish")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.noorGold)
                                .cornerRadius(16)
                        }
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loadLevel()
        }
    }
    
    func loadLevel() {
        if let level = CourseContent.getLevels(language: .english).first(where: { $0.id == levelNumber }) {
            let targetIds = level.contentIds
            self.words = CourseContent.words.filter { targetIds.contains($0.id) }
            
            if !words.isEmpty {
                loadWord(words[0])
            }
        }
    }
    
    func loadWord(_ word: ArabicWord) {
        showSuccess = false
        placedLetters = Array(repeating: nil, count: word.componentLetterIds.count)
        
        var letters: [ArabicLetter] = []
        for id in word.componentLetterIds {
            if let l = ArabicLetter.letter(byId: id) {
                letters.append(l)
            }
        }
        scrambledLetters = letters.shuffled()
    }
    
    func handleDrop(items: [String], at index: Int) -> Bool {
        guard let item = items.first, let letterId = Int(item) else { return false }
        guard let currentWord = currentWord else { return false }
        
        let correctLetterIdForSlot = currentWord.componentLetterIds[index]
        
        if letterId == correctLetterIdForSlot {
             AudioManager.shared.playSystemSound(1001)
            
            if let letter = ArabicLetter.letter(byId: letterId) {
                placedLetters[index] = letter
                
                if let idx = scrambledLetters.firstIndex(where: { $0.id == letterId && !isLetterUsed($0) }) {
                }
                
                checkCompletion()
            }
            return true
        } else {
             AudioManager.shared.playSystemSound(1002)
            return false
        }
    }
    
    func isLetterUsed(_ letter: ArabicLetter) -> Bool {
        let placedCount = placedLetters.compactMap { $0?.id }.filter { $0 == letter.id }.count
        let sourceCount = scrambledLetters.filter { $0.id == letter.id }.count
        
        return false 
    }
    
    func checkCompletion() {
        if placedLetters.allSatisfy({ $0 != nil }) {
            withAnimation {
                showSuccess = true
            }
        }
    }
    
    func nextWord() {
        if currentWordIndex < words.count - 1 {
            currentWordIndex += 1
            loadWord(words[currentWordIndex])
        } else {
            onCompletion()
        }
    }
}

struct LetterChip: View {
    let letter: ArabicLetter
    
    var body: some View {
        Text(letter.isolated)
            .font(.system(size: 32))
            .frame(width: 60, height: 60)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
