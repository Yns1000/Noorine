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
