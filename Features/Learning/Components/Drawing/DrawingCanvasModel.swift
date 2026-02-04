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
    
    func strokeColor(for strokeIndex: Int) -> Color {
        guard isValidated else { return .noorGold }
        return similarity >= 0.5 ? .green : .red
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
