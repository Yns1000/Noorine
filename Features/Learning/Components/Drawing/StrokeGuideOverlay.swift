import SwiftUI

struct StrokeGuideOverlay: View {
    let guides: [StrokeGuide]
    let canvasSize: CGSize
    @Binding var isVisible: Bool

    @State private var animationProgress: Double = 0
    @State private var currentStrokeIndex = 0
    @State private var showAll = false

    var body: some View {
        ZStack {
            if isVisible {
                ForEach(Array(guides.enumerated()), id: \.offset) { index, guide in
                    if guide.type == "dot" {
                        dotView(guide: guide, index: index)
                    } else {
                        strokeView(guide: guide, index: index)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: replay) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.noorGold)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color(.secondarySystemGroupedBackground))
                                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                                )
                        }
                        .padding(8)
                    }
                }
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .allowsHitTesting(false)
        .onAppear {
            startAnimation()
        }
    }

    private func dotView(guide: StrokeGuide, index: Int) -> some View {
        let point = guide.points[0]
        let x = point[0] * canvasSize.width
        let y = point[1] * canvasSize.height
        let visible = showAll || index <= currentStrokeIndex

        return ZStack {
            Circle()
                .fill(Color.noorGold.opacity(0.3))
                .frame(width: 20, height: 20)
                .scaleEffect(visible ? 1.2 : 0.5)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: visible)

            Circle()
                .fill(Color.noorGold)
                .frame(width: 10, height: 10)

            Text("\(index + 1)")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white)
        }
        .position(x: x, y: y)
        .opacity(visible ? 1 : 0)
        .animation(.easeIn(duration: 0.3), value: visible)
    }

    @ViewBuilder
    private func strokeView(guide: StrokeGuide, index: Int) -> some View {
        let points = guide.points.map { CGPoint(x: $0[0] * canvasSize.width, y: $0[1] * canvasSize.height) }
        let isCurrentlyAnimating = index == currentStrokeIndex && !showAll
        let isCompleted = showAll || index < currentStrokeIndex
        let visible = showAll || index <= currentStrokeIndex

        if visible, points.count >= 2 {
            ZStack {
                StrokePath(points: points, isCurve: guide.type == "curve")
                    .trim(from: 0, to: isCompleted ? 1 : (isCurrentlyAnimating ? animationProgress : 0))
                    .stroke(
                        Color.noorGold.opacity(0.6),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [8, 6])
                    )
                    .animation(.easeInOut(duration: 0.05), value: animationProgress)

                Circle()
                    .fill(Color.green)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Text("\(index + 1)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .position(points[0])
                    .opacity(visible ? 1 : 0)

                if isCompleted || (isCurrentlyAnimating && animationProgress > 0.7) {
                    arrowHead(points: points, isCurve: guide.type == "curve", progress: isCompleted ? 1.0 : animationProgress)
                }
            }
        }
    }

    private func arrowHead(points: [CGPoint], isCurve: Bool, progress: Double) -> some View {
        let linear = linearizedPoints(points, isCurve: isCurve)
        let totalLength = pathLength(points: linear)
        let targetLength = totalLength * progress
        let (position, angle) = pointAndAngle(along: linear, at: targetLength)

        return Triangle()
            .fill(Color.noorGold)
            .frame(width: 12, height: 10)
            .rotationEffect(.radians(angle + .pi / 2))
            .position(position)
    }

    private func startAnimation() {
        currentStrokeIndex = 0
        animationProgress = 0
        showAll = false
        animateNextStroke()
    }

    private func animateNextStroke() {
        guard currentStrokeIndex < guides.count else {
            withAnimation { showAll = true }
            return
        }

        let guide = guides[currentStrokeIndex]
        if guide.type == "dot" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                currentStrokeIndex += 1
                animateNextStroke()
            }
            return
        }

        animationProgress = 0
        let duration: Double = 0.6
        let steps = 30
        let interval = duration / Double(steps)

        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(step)) {
                animationProgress = Double(step) / Double(steps)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.2) {
            currentStrokeIndex += 1
            animateNextStroke()
        }
    }

    private func replay() {
        startAnimation()
    }

    private func linearizedPoints(_ controlPoints: [CGPoint], isCurve: Bool) -> [CGPoint] {
        guard controlPoints.count >= 2 else { return controlPoints }
        if !isCurve || controlPoints.count < 3 {
            return controlPoints
        }

        var result: [CGPoint] = [controlPoints[0]]
        let subdivisions = 20

        for i in 0..<(controlPoints.count - 1) {
            let p0 = controlPoints[max(0, i - 1)]
            let p1 = controlPoints[i]
            let p2 = controlPoints[i + 1]
            let p3 = controlPoints[min(controlPoints.count - 1, i + 2)]

            let cp1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6.0,
                              y: p1.y + (p2.y - p0.y) / 6.0)
            let cp2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6.0,
                              y: p2.y - (p3.y - p1.y) / 6.0)

            for s in 1...subdivisions {
                let t = Double(s) / Double(subdivisions)
                let mt = 1.0 - t
                let x = mt * mt * mt * p1.x + 3 * mt * mt * t * cp1.x + 3 * mt * t * t * cp2.x + t * t * t * p2.x
                let y = mt * mt * mt * p1.y + 3 * mt * mt * t * cp1.y + 3 * mt * t * t * cp2.y + t * t * t * p2.y
                result.append(CGPoint(x: x, y: y))
            }
        }
        return result
    }

    private func pathLength(points: [CGPoint]) -> Double {
        var length: Double = 0
        for i in 1..<points.count {
            let dx = points[i].x - points[i-1].x
            let dy = points[i].y - points[i-1].y
            length += sqrt(dx * dx + dy * dy)
        }
        return length
    }

    private func pointAndAngle(along points: [CGPoint], at distance: Double) -> (CGPoint, Double) {
        var remaining = distance
        for i in 1..<points.count {
            let dx = points[i].x - points[i-1].x
            let dy = points[i].y - points[i-1].y
            let segLen = sqrt(dx * dx + dy * dy)
            if remaining <= segLen || i == points.count - 1 {
                let t = segLen > 0 ? min(remaining / segLen, 1) : 0
                let x = points[i-1].x + dx * t
                let y = points[i-1].y + dy * t
                let angle = atan2(dy, dx)
                return (CGPoint(x: x, y: y), angle)
            }
            remaining -= segLen
        }
        let last = points.last ?? .zero
        return (last, 0)
    }
}

struct StrokePath: Shape {
    let points: [CGPoint]
    let isCurve: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count >= 2 else { return path }

        path.move(to: points[0])

        if isCurve && points.count >= 3 {
            for i in 0..<(points.count - 1) {
                let p0 = points[max(0, i - 1)]
                let p1 = points[i]
                let p2 = points[i + 1]
                let p3 = points[min(points.count - 1, i + 2)]
                let cp1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6.0,
                                  y: p1.y + (p2.y - p0.y) / 6.0)
                let cp2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6.0,
                                  y: p2.y - (p3.y - p1.y) / 6.0)
                path.addCurve(to: p2, control1: cp1, control2: cp2)
            }
        } else {
            for i in 1..<points.count {
                path.addLine(to: points[i])
            }
        }

        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
