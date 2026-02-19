import Foundation
import WatchConnectivity
#if canImport(UIKit)
import UIKit
#endif

class WatchSyncManager: NSObject {
    static let shared = WatchSyncManager()

    private override init() { super.init() }

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

#if os(watchOS)
    func sendDrawingComplete(letterId: Int, xp: Int) {
        guard WCSession.default.activationState == .activated else {
            print("WatchSyncManager: Cannot send drawing complete, session not activated")
            return
        }
        let message: [String: Any] = [
            "daily_draw_complete": true,
            "letterId": letterId,
            "xp": xp
        ]
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
            print("WatchSyncManager: sendMessage failed: \(error)")
        })
    }
    
    func validateDrawing(strokes: [[CGPoint]], expectedLetter: String, completion: @escaping (Bool?, Double) -> Void) {
        let session = WCSession.default
        
        guard session.activationState == .activated else {
            print("WatchSyncManager: session not activated yet. Fallback to local.")
            session.activate()
            completion(nil, 0)
            return
        }
        
        guard session.isReachable else {
            print("WatchSyncManager: iOS app is not reachable. Fallback to local.")
            completion(nil, 0)
            return
        }
        
        let serializedStrokes = strokes.map { stroke in
            stroke.map { ["x": Double($0.x), "y": Double($0.y)] }
        }
        
        let message: [String: Any] = [
            "type": "validate_drawing",
            "strokes": serializedStrokes,
            "expectedLetter": expectedLetter
        ]
        
        WCSession.default.sendMessage(message, replyHandler: { reply in
            let success = reply["success"] as? Bool ?? false
            let score = reply["score"] as? Double ?? 0.0
            completion(success, score)
        }, errorHandler: { error in
            print("WatchSyncManager: validateDrawing failed: \(error)")
            completion(nil, 0)
        })
    }
#endif
}

extension WatchSyncManager: WCSessionDelegate {
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if message["daily_draw_complete"] as? Bool == true {
            let xp = message["xp"] as? Int ?? 15
            DispatchQueue.main.async {
                DataManager.shared.addDailyChallengeXP(amount: xp)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        if message["type"] as? String == "validate_drawing" {
            guard let expectedLetter = message["expectedLetter"] as? String,
                  let serializedStrokes = message["strokes"] as? [[[String: Double]]] else {
                replyHandler(["success": false, "score": 0.0])
                return
            }
            
            let strokes: [[CGPoint]] = serializedStrokes.map { stroke in
                stroke.map { CGPoint(x: $0["x"] ?? 0, y: $0["y"] ?? 0) }
            }
            
            DispatchQueue.main.async {
                self.evaluateDrawingOniOS(strokes: strokes, expectedLetter: expectedLetter, replyHandler: replyHandler)
            }
        }
    }
    
    private func evaluateDrawingOniOS(strokes: [[CGPoint]], expectedLetter: String, replyHandler: @escaping ([String: Any]) -> Void) {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let allPoints = strokes.flatMap { $0 }
        let minX = allPoints.map(\.x).min() ?? 0
        let minY = allPoints.map(\.y).min() ?? 0
        let maxX = allPoints.map(\.x).max() ?? 1
        let maxY = allPoints.map(\.y).max() ?? 1
        
        let pathW = max(1, maxX - minX)
        let pathH = max(1, maxY - minY)
        
        let image = renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            UIColor.white.setStroke()
            for stroke in strokes {
                guard !stroke.isEmpty else { continue }
                let path = UIBezierPath()
                path.lineWidth = 12
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
        }
        
        let font = UIFont.systemFont(ofSize: 200, weight: .regular)
        let refImage = DrawingCanvasModel.renderReferenceLetter(expectedLetter, size: size, font: font)
        
        RecognitionEngine.evaluate(userDrawing: image, referenceImage: refImage, expectedLetter: expectedLetter) { result in
            replyHandler([
                "success": result.score >= 0.5,
                "score": result.score
            ])
        }
    }
#endif

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("WatchSyncManager: activation error: \(error)")
        }
#if os(iOS)
        if activationState == .activated {
            let lang = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "fr"
            try? WCSession.default.updateApplicationContext(["lang": lang])
        }
#endif
#if os(watchOS)
        if let lang = WCSession.default.receivedApplicationContext["lang"] as? String {
            UserDefaults.standard.set(lang, forKey: "selectedLanguage")
        }
#endif
    }

#if os(watchOS)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        if let lang = applicationContext["lang"] as? String {
            UserDefaults.standard.set(lang, forKey: "selectedLanguage")
        }
    }
#endif
}
