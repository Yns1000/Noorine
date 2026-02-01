import SwiftUI

struct SpeechBubble: View {
    let message: String
    let detail: String
    let accentColor: Color
    
    private let bubbleColor = Color(red: 0.10, green: 0.12, blue: 0.16)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey(message))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if !detail.isEmpty {
                Text(LocalizedStringKey(detail))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(minWidth: 200, maxWidth: 280, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(bubbleColor)
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(accentColor.opacity(0.35), lineWidth: 1.5)
            }
        )
    }
}

struct BubbleTriangle: View {
    let color: Color
    let borderColor: Color
    
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 20, y: 0))
                path.addLine(to: CGPoint(x: 10, y: 12))
                path.closeSubpath()
            }
            .fill(color)
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 10, y: 12))
                path.addLine(to: CGPoint(x: 20, y: 0))
            }
            .stroke(borderColor.opacity(0.35), lineWidth: 1.5)
        }
        .frame(width: 20, height: 12)
    }
}

struct MascotWithBubble: View {
    let message: String
    let detail: String
    let accentColor: Color
    let mood: EmotionalMascot.Mood
    var mascotSize: CGFloat = 75
    var onSkipToPronunciation: (() -> Void)? = nil
    
    private let bubbleColor = Color(red: 0.10, green: 0.12, blue: 0.16)
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                SpeechBubble(
                    message: message,
                    detail: detail,
                    accentColor: accentColor
                )
                
                HStack(spacing: 0) {
                    Spacer().frame(width: 40)
                    
                    BubbleTriangle(color: bubbleColor, borderColor: accentColor)
                        .offset(y: -1)
                }
                
                Spacer().frame(height: 6)
                
                HStack(spacing: 0) {
                    Spacer().frame(width: 8)
                    
                    EmotionalMascot(mood: mood, size: mascotSize, showAura: false)
                        .frame(width: mascotSize, height: mascotSize)
                }
            }
            
            Spacer()
        }
        .padding(.leading, 16)
    }
}

