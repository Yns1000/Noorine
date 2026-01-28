import SwiftUI
import UIKit

struct FreeDrawingStep: View {
    let letter: ArabicLetter
    let formType: LetterFormType
    let onComplete: () -> Void
    
    @StateObject private var model = DrawingCanvasModel()
    @State private var showSuccess = false
    @State private var mascotMessage = "Le savais-tu ?"
    @State private var mascotDetail = ArabicFunFacts.randomFact()
    @State private var accentColor = Color.noorGold
    @State private var mascotMood: EmotionalMascot.Mood = .neutral
    @State private var showManualValidation = false
    @State private var currentFunFact = ArabicFunFacts.randomFact()
    @State private var hasTriedOnce = false
    
    let canvasSize = CGSize(width: 250, height: 250)
    let requiredScore: Double = 0.50
    
    var currentForm: String {
        formType.getForm(from: letter)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("Forme \(formType.rawValue.lowercased())")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.noorSecondary)
                
                Text(currentForm)
                    .font(.system(size: 90, weight: .regular))
                    .foregroundColor(.noorGold)
            }
            .padding(.top, 8)
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(UIColor.systemBackground).opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                showSuccess ? Color.green : Color.noorSecondary.opacity(0.3),
                                lineWidth: showSuccess ? 3 : 2
                            )
                    )
                
                FreeDrawingCanvas(
                    model: model,
                    referenceText: currentForm,
                    canvasSize: canvasSize
                )
            }
            .frame(width: canvasSize.width + 10, height: canvasSize.height + 10)
            .padding(.top, 8)
            
            if hasTriedOnce && model.hasContent {
                HStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                            
                            Capsule()
                                .fill(similarityColor)
                                .frame(width: geo.size.width * model.similarity)
                                .animation(.easeInOut, value: model.similarity)
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(Int(model.similarity * 100))%")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(similarityColor)
                        .frame(width: 32)
                }
                .padding(.horizontal, 50)
                .padding(.top, 8)
            }
            
            HStack(spacing: 12) {
                Button(action: clearDrawing) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Effacer")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.noorSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .stroke(Color.noorSecondary.opacity(0.3), lineWidth: 1.5)
                    )
                }
                
                Button(action: validateDrawing) {
                    HStack(spacing: 4) {
                        if model.isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(.white)
                        } else {
                            Image(systemName: showSuccess ? "checkmark" : "sparkle.magnifyingglass")
                        }
                        Text(showSuccess ? "Continuer" : "Vérifier")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
                    .background(
                        Capsule()
                            .fill(
                                showSuccess
                                    ? LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [.noorGold, .noorGold.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                            )
                    )
                }
                .disabled(model.strokes.isEmpty || model.isAnalyzing)
            }
            .padding(.top, 12)
            
            if showManualValidation && !showSuccess {
                Button(action: manualValidation) {
                    Text("Je pense que c'est correct")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.noorSecondary.opacity(0.8))
                        .underline()
                }
                .padding(.top, 8)
            }
            
            Spacer()
            
            HStack(alignment: .center, spacing: 8) {
                EmotionalMascot(mood: mascotMood, size: 80)
                
                SpeechBubble(
                    message: mascotMessage,
                    detail: mascotDetail,
                    accentColor: accentColor
                )
                .offset(y: -12)
                
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.trailing, 16)
            .padding(.bottom, 50)
        }
    }
    
    var similarityColor: Color {
        if model.similarity >= requiredScore {
            return .green
        } else if model.similarity >= requiredScore * 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func clearDrawing() {
        model.clear()
        let newFact = ArabicFunFacts.randomFact()
        mascotMessage = "Le savais-tu ?"
        mascotDetail = newFact
        accentColor = .noorGold
        showSuccess = false
        mascotMood = .neutral
        showManualValidation = false
    }
    
    private func manualValidation() {
        showSuccess = true
        model.isValidated = true
        mascotMood = .happy
        mascotMessage = "Je te fais confiance"
        mascotDetail = "Excuse-moi si mon analyse n'était pas juste"
        accentColor = .green
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func validateDrawing() {
        if showSuccess {
            onComplete()
            return
        }
        
        model.isAnalyzing = true
        mascotMood = .thinking
        mascotMessage = "Hmm, laisse-moi voir..."
        mascotDetail = ""
        accentColor = .noorGold
        
        let userDrawing = model.renderDrawing(size: canvasSize)
        let fontSize = min(canvasSize.width, canvasSize.height) * 0.65
        let font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        let referenceImage = DrawingCanvasModel.renderReferenceLetter(currentForm, size: canvasSize, font: font)
        
        RecognitionEngine.evaluate(
            userDrawing: userDrawing,
            referenceImage: referenceImage,
            expectedLetter: currentForm
        ) { result in
            model.similarity = result.score
            model.recognizedText = result.recognizedText ?? ""
            model.isAnalyzing = false
            hasTriedOnce = true
            
            if result.score >= requiredScore {
                showSuccess = true
                model.isValidated = true
                mascotMood = .happy
                mascotMessage = "Bravo, c'est parfait"
                mascotDetail = "Tu maîtrises cette forme"
                accentColor = .green
                showManualValidation = false
                
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else if result.score >= requiredScore * 0.6 {
                mascotMood = .neutral
                mascotMessage = "Tu y es presque"
                accentColor = .orange
                showManualValidation = true
                
                if let shape = result.shapeAnalysis {
                    if shape.strokeCoverage < 0.4 {
                        mascotDetail = "Essaie de couvrir toute la lettre"
                    } else if shape.overflowPenalty > 0.4 {
                        mascotDetail = "Reste dans les limites"
                    } else {
                        mascotDetail = ArabicFunFacts.randomEncouragement()
                    }
                }
                
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            } else {
                mascotMood = .sad
                mascotMessage = "On réessaie ensemble"
                mascotDetail = ArabicFunFacts.randomEncouragement()
                accentColor = .noorSecondary
                showManualValidation = true
                
                currentFunFact = ArabicFunFacts.randomFact()
            }
        }
    }
}
import SwiftUI
import UIKit
import Combine

class DrawingCanvasModel: ObservableObject {
    @Published var strokes: [[CGPoint]] = []
    @Published var currentStroke: [CGPoint] = []
    @Published var similarity: Double = 0
    @Published var isValidated: Bool = false
    @Published var isAnalyzing: Bool = false
    @Published var recognizedText: String = ""
    
    func addPoint(_ point: CGPoint) {
        currentStroke.append(point)
    }
    
    func finishStroke() {
        if !currentStroke.isEmpty {
            strokes.append(currentStroke)
            currentStroke = []
        }
    }
    
    func clear() {
        strokes = []
        currentStroke = []
        similarity = 0
        isValidated = false
        recognizedText = ""
    }
    
    var hasContent: Bool {
        !strokes.isEmpty || !currentStroke.isEmpty
    }
    
    func renderDrawing(size: CGSize, strokeColor: UIColor = .white, lineWidth: CGFloat = 12) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            strokeColor.setStroke()
            
            for stroke in strokes {
                guard !stroke.isEmpty else { continue }
                
                let path = UIBezierPath()
                path.lineWidth = lineWidth
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                
                path.move(to: stroke[0])
                if stroke.count == 1 {
                    path.addLine(to: stroke[0])
                } else {
                    for i in 1..<stroke.count {
                        path.addLine(to: stroke[i])
                    }
                }
                path.stroke()
            }
            
            if !currentStroke.isEmpty {
                let path = UIBezierPath()
                path.lineWidth = lineWidth
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                
                path.move(to: currentStroke[0])
                if currentStroke.count == 1 {
                    path.addLine(to: currentStroke[0])
                } else {
                    for i in 1..<currentStroke.count {
                        path.addLine(to: currentStroke[i])
                    }
                }
                path.stroke()
            }
        }
    }
    
    static func renderReferenceLetter(_ letter: String, size: CGSize, font: UIFont) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let textSize = letter.size(withAttributes: attrs)
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            letter.draw(in: rect, withAttributes: attrs)
        }
    }
}
import SwiftUI

struct FreeDrawingCanvas: View {
    @ObservedObject var model: DrawingCanvasModel
    let referenceText: String
    let canvasSize: CGSize
    
    var body: some View {
        ZStack {
            Text(referenceText)
                .font(.system(size: min(canvasSize.width, canvasSize.height) * 0.65, weight: .regular))
                .foregroundColor(.gray.opacity(0.2))
            
            Canvas { context, size in
                for stroke in model.strokes {
                    if !stroke.isEmpty {
                        var path = Path()
                        path.move(to: stroke[0])
                        if stroke.count == 1 {
                            path.addLine(to: stroke[0])
                        } else {
                            for i in 1..<stroke.count {
                                path.addLine(to: stroke[i])
                            }
                        }
                        context.stroke(path, with: .color(.noorGold), style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    }
                }
                
                if !model.currentStroke.isEmpty {
                    var path = Path()
                    path.move(to: model.currentStroke[0])
                    if model.currentStroke.count == 1 {
                        path.addLine(to: model.currentStroke[0])
                    } else {
                        for i in 1..<model.currentStroke.count {
                            path.addLine(to: model.currentStroke[i])
                        }
                    }
                    context.stroke(path, with: .color(.noorGold), style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        model.addPoint(value.location)
                    }
                    .onEnded { _ in
                        model.finishStroke()
                    }
            )
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
import SwiftUI
import Vision
import UIKit

class HandwritingRecognizer {
    static func recognizeText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let fullText = recognizedStrings.joined()
            completion(fullText.isEmpty ? nil : fullText)
        }
        
        request.recognitionLanguages = ["ar", "ar-SA"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    static func compareLetters(recognized: String?, expected: String) -> Double {
        guard let recognized = recognized, !recognized.isEmpty else {
            return 0
        }
        
        let normalizedRecognized = normalizeArabic(recognized)
        let normalizedExpected = normalizeArabic(expected)
        
        if normalizedRecognized.contains(normalizedExpected) || 
           normalizedExpected.contains(normalizedRecognized) {
            return 1.0
        }
        
        let baseRecognized = getBaseLetter(normalizedRecognized)
        let baseExpected = getBaseLetter(normalizedExpected)
        
        if baseRecognized == baseExpected {
            return 0.9
        }
        
        if areSimilarLetters(baseRecognized, baseExpected) {
            return 0.7
        }
        
        return 0
    }
    
    private static func normalizeArabic(_ text: String) -> String {
        let diacritics = CharacterSet(charactersIn: "\u{064B}\u{064C}\u{064D}\u{064E}\u{064F}\u{0650}\u{0651}\u{0652}\u{0640}")
        return text.unicodeScalars.filter { !diacritics.contains($0) }.map { String($0) }.joined()
    }
    
    private static func getBaseLetter(_ text: String) -> Character? {
        let baseLetterMap: [Character: Character] = [
            "ا": "ا", "أ": "ا", "إ": "ا", "آ": "ا",
            "ب": "ب", "ت": "ت", "ث": "ث", 
            "ج": "ج", "ح": "ح", "خ": "خ",
            "د": "د", "ذ": "ذ", "ر": "ر", "ز": "ز",
            "س": "س", "ش": "ش", "ص": "ص", "ض": "ض",
            "ط": "ط", "ظ": "ظ", "ع": "ع", "غ": "غ",
            "ف": "ف", "ق": "ق", "ك": "ك", "ل": "ل",
            "م": "م", "ن": "ن", "ه": "ه", "و": "و", "ي": "ي"
        ]
        
        return text.first.flatMap { baseLetterMap[$0] ?? $0 }
    }
    
    private static func areSimilarLetters(_ a: Character?, _ b: Character?) -> Bool {
        guard let a = a, let b = b else { return false }
        
        let similarGroups: [[Character]] = [
            ["ب", "ت", "ث", "ن", "ي"],
            ["ج", "ح", "خ"],
            ["د", "ذ"],
            ["ر", "ز"],
            ["س", "ش"],
            ["ص", "ض"],
            ["ط", "ظ"],
            ["ع", "غ"],
            ["ف", "ق"]
        ]
        
        for group in similarGroups {
            if group.contains(a) && group.contains(b) {
                return true
            }
        }
        
        return false
    }
}

class ShapeAnalyzer {
    
    static func analyzeShape(userImage: UIImage, referenceImage: UIImage) -> ShapeAnalysis {
        guard let userCG = userImage.cgImage, let refCG = referenceImage.cgImage else {
            return ShapeAnalysis(boundingBoxMatch: 0, strokeCoverage: 0, overflowPenalty: 0)
        }
        
        let gridSize = 20
        let size = CGSize(width: gridSize, height: gridSize)
        
        guard let userPixels = getPixelData(from: userCG, targetSize: size),
              let refPixels = getPixelData(from: refCG, targetSize: size) else {
            return ShapeAnalysis(boundingBoxMatch: 0, strokeCoverage: 0, overflowPenalty: 0)
        }
        
        let boundingBoxMatch = calculateBoundingBoxMatch(userPixels, refPixels, gridSize: gridSize)
        let strokeCoverage = calculateStrokeCoverage(userPixels, refPixels)
        let overflowPenalty = calculateOverflowPenalty(userPixels, refPixels)
        
        return ShapeAnalysis(
            boundingBoxMatch: boundingBoxMatch,
            strokeCoverage: strokeCoverage,
            overflowPenalty: overflowPenalty
        )
    }
    
    private static func calculateBoundingBoxMatch(_ user: [UInt8], _ ref: [UInt8], gridSize: Int) -> Double {
        let userBB = findBoundingBox(user, gridSize: gridSize)
        let refBB = findBoundingBox(ref, gridSize: gridSize)
        
        guard let uBB = userBB, let rBB = refBB else { return 0 }
        
        let userRatio = Double(uBB.width) / max(1, Double(uBB.height))
        let refRatio = Double(rBB.width) / max(1, Double(rBB.height))
        
        let ratioDiff = abs(userRatio - refRatio)
        let ratioScore = max(0, 1.0 - ratioDiff * 0.5)
        
        let userCenterX = Double(uBB.minX + uBB.width / 2) / Double(gridSize)
        let userCenterY = Double(uBB.minY + uBB.height / 2) / Double(gridSize)
        let refCenterX = Double(rBB.minX + rBB.width / 2) / Double(gridSize)
        let refCenterY = Double(rBB.minY + rBB.height / 2) / Double(gridSize)
        
        let centerDist = sqrt(pow(userCenterX - refCenterX, 2) + pow(userCenterY - refCenterY, 2))
        let positionScore = max(0, 1.0 - centerDist * 2)
        
        return (ratioScore + positionScore) / 2
    }
    
    private static func findBoundingBox(_ pixels: [UInt8], gridSize: Int) -> (minX: Int, minY: Int, width: Int, height: Int)? {
        var minX = gridSize, maxX = 0, minY = gridSize, maxY = 0
        let threshold: UInt8 = 50
        
        for y in 0..<gridSize {
            for x in 0..<gridSize {
                if pixels[y * gridSize + x] > threshold {
                    minX = min(minX, x)
                    maxX = max(maxX, x)
                    minY = min(minY, y)
                    maxY = max(maxY, y)
                }
            }
        }
        
        guard maxX >= minX && maxY >= minY else { return nil }
        return (minX, minY, maxX - minX + 1, maxY - minY + 1)
    }
    
    private static func calculateStrokeCoverage(_ user: [UInt8], _ ref: [UInt8]) -> Double {
        var refCount = 0
        var coveredCount = 0
        let threshold: UInt8 = 50
        let coverThreshold: UInt8 = 30
        
        for i in 0..<ref.count {
            if ref[i] > threshold {
                refCount += 1
                if user[i] > coverThreshold {
                    coveredCount += 1
                }
            }
        }
        
        return refCount > 0 ? Double(coveredCount) / Double(refCount) : 0
    }
    
    private static func calculateOverflowPenalty(_ user: [UInt8], _ ref: [UInt8]) -> Double {
        var userOnlyCount = 0
        var userTotalCount = 0
        let threshold: UInt8 = 50
        
        for i in 0..<user.count {
            if user[i] > threshold {
                userTotalCount += 1
                if ref[i] <= threshold {
                    userOnlyCount += 1
                }
            }
        }
        
        return userTotalCount > 0 ? Double(userOnlyCount) / Double(userTotalCount) : 0
    }
    
    private static func getPixelData(from cgImage: CGImage, targetSize: CGSize) -> [UInt8]? {
        let width = Int(targetSize.width)
        let height = Int(targetSize.height)
        
        var pixelData = [UInt8](repeating: 0, count: width * height)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }
        
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return pixelData
    }
}

struct ShapeAnalysis {
    let boundingBoxMatch: Double
    let strokeCoverage: Double
    let overflowPenalty: Double
    
    var combinedScore: Double {
        let coverageWeight = 0.5
        let boundingWeight = 0.3
        let overflowWeight = 0.2
        
        let overflowScore = max(0, 1.0 - overflowPenalty * 2)
        
        return strokeCoverage * coverageWeight + 
               boundingBoxMatch * boundingWeight + 
               overflowScore * overflowWeight
    }
}

class RecognitionEngine {
    
    static func evaluate(
        userDrawing: UIImage,
        referenceImage: UIImage,
        expectedLetter: String,
        completion: @escaping (RecognitionResult) -> Void
    ) {
        var textResult: String?
        var shapeAnalysis: ShapeAnalysis?
        
        let group = DispatchGroup()
        
        group.enter()
        HandwritingRecognizer.recognizeText(from: userDrawing) { recognized in
            textResult = recognized
            group.leave()
        }
        
        group.enter()
        DispatchQueue.global(qos: .userInteractive).async {
            shapeAnalysis = ShapeAnalyzer.analyzeShape(
                userImage: userDrawing,
                referenceImage: referenceImage
            )
            group.leave()
        }
        
        group.notify(queue: .main) {
            let textScore = HandwritingRecognizer.compareLetters(
                recognized: textResult,
                expected: expectedLetter
            )
            
            let shapeScore = shapeAnalysis?.combinedScore ?? 0
            
            var finalScore: Double
            
            if textScore >= 0.7 {
                finalScore = max(textScore, shapeScore)
            } else if textScore > 0 && textScore < 0.5 {
                finalScore = shapeScore * 0.3
            } else {
                finalScore = shapeScore * 0.8
            }
            
            if let shape = shapeAnalysis, shape.strokeCoverage < 0.3 {
                finalScore = min(finalScore, shape.strokeCoverage)
            }
            
            if let shape = shapeAnalysis, shape.overflowPenalty > 0.5 {
                finalScore *= (1.0 - shape.overflowPenalty * 0.5)
            }
            
            completion(RecognitionResult(
                score: finalScore,
                recognizedText: textResult,
                shapeAnalysis: shapeAnalysis
            ))
        }
    }
}

struct RecognitionResult {
    let score: Double
    let recognizedText: String?
    let shapeAnalysis: ShapeAnalysis?
}
import SwiftUI

struct EmotionalMascot: View {
    enum Mood {
        case neutral
        case happy
        case sad
        case thinking
    }
    
    let mood: Mood
    let size: CGFloat
    
    @State private var isBlinking = false
    @State private var bounceOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [moodColor, moodColor.opacity(0.6)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.5
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(color: moodColor.opacity(0.5), radius: size * 0.25)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.8), lineWidth: 2).padding(2)
                    )
                
                Group {
                    HStack(spacing: size * 0.2) {
                        eyeView
                        eyeView
                    }
                    .offset(y: -size * 0.12)
                    
                    mouthView
                        .offset(y: size * 0.05)
                    
                    Circle()
                        .fill(Color(red: 0.8, green: 0.4, blue: 0.1).opacity(0.6))
                        .frame(width: size * 0.06, height: size * 0.06)
                        .offset(x: -size * 0.22, y: size * 0.03)
                }
            }
            .offset(y: bounceOffset)
        }
        .onAppear {
            startBlinking()
            if mood == .happy {
                startBouncing()
            }
        }
        .onChange(of: mood) { newMood in
            if newMood == .happy {
                startBouncing()
            }
        }
    }
    
    private var moodColor: Color {
        switch mood {
        case .neutral: return .noorGold
        case .happy: return .noorGold
        case .sad: return .orange.opacity(0.7)
        case .thinking: return .noorGold.opacity(0.8)
        }
    }
    
    @ViewBuilder
    private var eyeView: some View {
        Group {
            if mood == .sad {
                Ellipse()
                    .frame(width: size * 0.08, height: size * 0.06)
                    .foregroundColor(Color.white.opacity(0.9))
            } else {
                Ellipse()
                    .frame(width: size * 0.08, height: size * 0.1)
                    .foregroundColor(Color.white.opacity(0.9))
                    .scaleEffect(y: isBlinking ? 0.1 : 1.0)
            }
        }
    }
    
    @ViewBuilder
    private var mouthView: some View {
        switch mood {
        case .neutral, .thinking:
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.8))
                .frame(width: size * 0.25, height: 2)
        case .happy:
            Circle()
                .trim(from: 0.1, to: 0.4)
                .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .frame(width: size * 0.35, height: size * 0.35)
        case .sad:
            Circle()
                .trim(from: 0.6, to: 0.9)
                .stroke(Color.white.opacity(0.8), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: size * 0.3, height: size * 0.3)
        }
    }
    
    private func startBlinking() {
        guard mood != .sad else { return }
        
        let randomInterval = Double.random(in: 2.0...4.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + randomInterval) {
            withAnimation(.easeInOut(duration: 0.15)) {
                isBlinking = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isBlinking = false
                }
                startBlinking()
            }
        }
    }
    
    private func startBouncing() {
        withAnimation(.easeInOut(duration: 0.3)) {
            bounceOffset = -8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                bounceOffset = 0
            }
        }
    }
}
import SwiftUI

struct SpeechBubble: View {
    let message: String
    let detail: String
    let accentColor: Color
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            LeftPointingTriangle()
                .fill(Color(red: 0.12, green: 0.14, blue: 0.18))
                .frame(width: 14, height: 24)
                .overlay(
                    LeftPointingTriangle()
                        .stroke(accentColor.opacity(0.4), lineWidth: 1.5)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(message)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.noorText)
                
                if !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.noorSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.12, green: 0.14, blue: 0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [accentColor.opacity(0.5), accentColor.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
    }
}

struct LeftPointingTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        
        return path
    }
}
import Foundation

struct ArabicFunFacts {
    static let facts = [
        "L'arabe est parlé par plus de 420 millions de personnes dans le monde.",
        "L'alphabet arabe compte 28 lettres, toutes des consonnes.",
        "L'arabe s'écrit de droite à gauche, une particularité partagée avec l'hébreu.",
        "Le mot 'algorithme' vient du mathématicien arabe Al-Khwarizmi.",
        "L'arabe est l'une des 6 langues officielles de l'ONU.",
        "Chaque lettre arabe peut avoir jusqu'à 4 formes différentes.",
        "Le Coran est écrit en arabe classique, considéré comme la forme la plus pure.",
        "L'arabe a influencé de nombreuses langues : espagnol, portugais, français...",
        "Le mot 'café' vient de l'arabe 'qahwa'.",
        "L'arabe possède plus de 12 millions de mots, contre 600 000 en anglais.",
        "La calligraphie arabe est considérée comme un art majeur dans le monde islamique.",
        "Les chiffres 'arabes' que nous utilisons viennent en fait de l'Inde.",
        "L'arabe distingue les nombres singulier, duel (pour 2) et pluriel.",
        "Le plus ancien texte arabe date du 1er siècle avant J.-C.",
        "L'arabe a 3 voyelles longues et 3 voyelles courtes."
    ]
    
    static let encouragements = [
        "La persévérance est la clé de l'apprentissage.",
        "Chaque erreur est une opportunité d'apprendre.",
        "Les plus grands calligraphes ont tous commencé comme toi.",
        "La patience est le secret des maîtres arabes.",
        "Continue, tu progresses à chaque essai.",
        "L'apprentissage est un voyage, pas une destination.",
        "Même les experts ont eu besoin de pratique.",
        "Ton effort d'aujourd'hui est ton succès de demain."
    ]
    
    static func randomFact() -> String {
        facts.randomElement() ?? facts[0]
    }
    
    static func randomEncouragement() -> String {
        encouragements.randomElement() ?? encouragements[0]
    }
}
