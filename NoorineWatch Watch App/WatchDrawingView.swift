import SwiftUI
import WatchKit
import Combine

enum PracticeItem: Equatable {
    case letter(ArabicLetter)
    case word(ArabicWord)
    
    var id: String {
        switch self {
        case .letter(let l): return "letter_\(l.id)"
        case .word(let w): return "word_\(w.id)"
        }
    }
    
    var guide: String {
        switch self {
        case .letter(let l): return l.isolated
        case .word(let w): return w.arabic
        }
    }
    
    var subText: String {
        switch self {
        case .letter(let l): return l.transliteration
        case .word(let w): return w.transliteration
        }
    }
    
    var isLetter: Bool {
        switch self {
        case .letter: return true
        case .word: return false
        }
    }
    
    var translation: String? {
        switch self {
        case .letter: return nil
        case .word(let w): return Locale.current.language.languageCode?.identifier == "en" ? w.translationEn : w.translationFr
        }
    }
    
    var xpReward: Int {
        switch self {
        case .letter: return 15
        case .word: return 25
        }
    }
}

struct WatchDrawingView: View {
    enum SessionPhase {
        case drawing, validating, success, allCompleted
    }

    @State private var phase: SessionPhase = .drawing
    @State private var currentItem: PracticeItem?
    @State private var dailyProgress: Int = 0
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []
    @State private var warningMessage: String?
    @State private var isOfflineMode: Bool = false
    
    @AppStorage("NoorineWatchHideTutorial_v7") private var hideTutorial: Bool = false
    @State private var showTutorial: Bool = false
    @State private var inactivityTimer: Timer?
    
    private let gold = Color(red: 0.85, green: 0.65, blue: 0.2)
    private var isEnglish: Bool { Locale.current.language.languageCode?.identifier == "en" }
    private var canValidate: Bool { !strokes.isEmpty || !currentStroke.isEmpty }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch phase {
            case .drawing:
                if let item = currentItem {
                    drawingView(for: item)
                } else {
                    ProgressView().tint(gold)
                }
            case .validating:
                validatingView()
            case .success:
                successView()
            case .allCompleted:
                allCompletedView()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if currentItem == nil { nextItem() }
            if !hideTutorial { showTutorial = true }
            restartInactivityTimer()
        }
    }

    private func drawingView(for item: PracticeItem) -> some View {
        ZStack {
            Color(white: 0.1).ignoresSafeArea()

            Text(item.guide)
                .font(.system(size: 160, design: .serif))
                .minimumScaleFactor(0.2)
                .lineLimit(1)
                .foregroundStyle(Color.white.opacity(0.12))
                .padding(.horizontal, 10)
                .allowsHitTesting(false)
            
            Canvas { context, _ in
                for stroke in strokes { drawStroke(stroke, in: &context, alpha: 1.0) }
                if !currentStroke.isEmpty { drawStroke(currentStroke, in: &context, alpha: 0.8) }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { val in
                        if showTutorial { withAnimation { showTutorial = false } }
                        currentStroke.append(val.location)
                        warningMessage = nil
                        restartInactivityTimer()
                    }
                    .onEnded { _ in
                        if currentStroke.count >= 1 { strokes.append(currentStroke) }
                        currentStroke = []
                        restartInactivityTimer()
                    }
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: {
                        if canValidate { validateDrawing() }
                        else { WKInterfaceDevice.current().play(.click) }
                    }) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(item.subText.capitalized)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(gold)
                            
                            Text(item.translation ?? (isEnglish ? "Letter" : "Lettre"))
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.leading, 6)
                .padding(.top, 12)
                .ignoresSafeArea(edges: .top)
                
                Spacer()
                
                if canValidate && !showTutorial {
                    Button(action: resetCanvas) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14))
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    .padding(.leading, 8)
                    .padding(.bottom, 4)
                }
            }
            
            if let warning = warningMessage {
                Text(warning)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 10)
            }

            if showTutorial {
                tutorialOverlay()
            }
        }
    }

    private func tutorialOverlay() -> some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    VStack(spacing: 5) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(gold)
                        Text(isEnglish ? "1. Draw" : "1. Dessiner")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 5) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(gold)
                        Text(isEnglish ? "2. Tap Word" : "2. Toucher Mot")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 10)
                
                Button(action: { withAnimation { showTutorial = false } }) {
                    Text("OK")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 80, height: 32)
                        .background(gold)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                Button(action: { withAnimation { hideTutorial = true; showTutorial = false } }) {
                    Text(isEnglish ? "Never show again" : "Ne plus afficher")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .zIndex(20)
    }

    private func validatingView() -> some View {
        VStack(spacing: 12) {
            ProgressView().tint(gold).scaleEffect(1.5)
            Text(isEnglish ? "Analyzing..." : "Analyse...")
                .font(.system(size: 15, weight: .bold)).foregroundStyle(gold)
        }
    }
    
    private func successView() -> some View {
        VStack(spacing: 6) {
            Image(systemName: "star.circle.fill").font(.system(size: 40)).foregroundStyle(gold).symbolEffect(.bounce.up)
            Text(isEnglish ? "Excellent!" : "Excellent !").font(.system(size: 18, weight: .black))
            if isOfflineMode {
                Text(isEnglish ? "(Offline: Low Precision)" : "(Hors ligne : Précision Réduite)")
                    .font(.system(size: 10)).foregroundStyle(.orange)
            }
            if let item = currentItem { Text("+\(item.xpReward) XP").font(.system(size: 14, weight: .bold)).foregroundStyle(gold) }
            Button(action: nextItem) {
                Text(isEnglish ? "Continue" : "Continuer")
                    .font(.system(size: 15, weight: .bold)).foregroundStyle(.black)
                    .frame(maxWidth: .infinity, minHeight: 40).background(gold).clipShape(Capsule())
            }
            .buttonStyle(.plain).padding(.horizontal, 16).padding(.top, 4)
        }
    }

    private func allCompletedView() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill").font(.system(size: 44)).foregroundStyle(gold)
            Text(isEnglish ? "Incredible!" : "Incroyable !").font(.system(size: 16, weight: .bold))
            Button { UserDefaults.standard.set([], forKey: "NoorineWatchDoneIds"); nextItem() } label: {
                Image(systemName: "arrow.clockwise").font(.system(size: 18, weight: .bold)).foregroundStyle(.black)
                    .frame(width: 48, height: 48).background(gold).clipShape(Circle())
            }
            .buttonStyle(.plain).padding(.top, 4)
        }
    }
    
    private func nextItem() {
        let doneIds = UserDefaults.standard.stringArray(forKey: "NoorineWatchDoneIds") ?? []
        let letters = CourseContent.letters.filter { !doneIds.contains("letter_\($0.id)") }
        let words = CourseContent.words.filter { !doneIds.contains("word_\($0.id)") && $0.arabic.count <= 4 }
        if letters.isEmpty && words.isEmpty { withAnimation { phase = .allCompleted }; return }
        if Bool.random() && !letters.isEmpty { currentItem = .letter(letters.randomElement()!) }
        else { currentItem = .word(words.randomElement()!) }
        resetCanvas(); phase = .drawing; restartInactivityTimer()
    }
    
    private func validateDrawing() {
        guard canValidate, let item = currentItem else { return }
        inactivityTimer?.invalidate(); withAnimation { phase = .validating }
        WatchSyncManager.shared.validateDrawing(strokes: strokes, expectedLetter: item.guide) { success, _ in
            DispatchQueue.main.async {
                if let success = success {
                    self.isOfflineMode = false
                    if success { self.handleValidationSuccess(for: item) }
                    else { WKInterfaceDevice.current().play(.failure); self.resetCanvas(); withAnimation { self.phase = .drawing } }
                } else { self.isOfflineMode = true; self.handleValidationSuccess(for: item) }
            }
        }
    }
    
    private func handleValidationSuccess(for item: PracticeItem) {
        WKInterfaceDevice.current().play(.success)
        var doneIds = UserDefaults.standard.stringArray(forKey: "NoorineWatchDoneIds") ?? []
        if !doneIds.contains(item.id) { doneIds.append(item.id); UserDefaults.standard.set(doneIds, forKey: "NoorineWatchDoneIds") }
        let idInt = Int(item.id.components(separatedBy: "_").last ?? "0") ?? 0
        WatchSyncManager.shared.sendDrawingComplete(letterId: idInt, xp: item.xpReward)
        withAnimation { phase = .success }
    }
    
    private func resetCanvas() { strokes = []; currentStroke = []; warningMessage = nil }
    private func drawStroke(_ pts: [CGPoint], in context: inout GraphicsContext, alpha: Double) {
        guard !pts.isEmpty else { return }
        var path = Path(); path.move(to: pts[0])
        for i in 1..<pts.count { path.addLine(to: pts[i]) }
        context.stroke(path, with: .color(gold.opacity(alpha)), style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
    }
    private func restartInactivityTimer() {
        inactivityTimer?.invalidate(); guard !hideTutorial else { return }
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 40.0, repeats: false) { _ in
            DispatchQueue.main.async { if phase == .drawing { withAnimation { showTutorial = true } } }
        }
    }
    private func loadDailyProgress() {}
}