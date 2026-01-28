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
