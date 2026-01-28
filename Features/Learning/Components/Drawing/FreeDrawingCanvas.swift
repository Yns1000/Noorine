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
