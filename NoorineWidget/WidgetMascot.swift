import SwiftUI

struct WidgetMascot: View {
    var size: CGFloat = 36

    private let goldColor = Color(red: 0.85, green: 0.65, blue: 0.2)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [goldColor, goldColor.opacity(0.6)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: goldColor.opacity(0.4), radius: size * 0.15)
                .overlay(
                    Circle().stroke(Color.white.opacity(0.8), lineWidth: 1.5).padding(1)
                )

            HStack(spacing: size * 0.2) {
                Ellipse()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: size * 0.075, height: size * 0.1)
                Ellipse()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: size * 0.075, height: size * 0.1)
            }
            .offset(y: -size * 0.12)

            Circle()
                .trim(from: 0.1, to: 0.4)
                .stroke(Color.white.opacity(0.85), style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))
                .frame(width: size * 0.42, height: size * 0.42)
                .offset(y: size * 0.025)

            Circle()
                .fill(Color(red: 0.75, green: 0.35, blue: 0.1))
                .frame(width: size * 0.07, height: size * 0.07)
                .offset(x: -size * 0.24, y: size * 0.04)
        }
    }
}
