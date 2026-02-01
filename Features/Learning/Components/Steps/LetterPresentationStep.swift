import SwiftUI

struct LetterPresentationStep: View {
    let letter: ArabicLetter
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.noorGold.opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(animate ? 1.1 : 1.0)
                
                Text(letter.isolated)
                    .font(.system(size: 120, weight: .medium))
                    .foregroundColor(.noorText)
            }
            .onTapGesture {
                AudioManager.shared.playLetter(letter.isolated)
                HapticManager.shared.impact(.medium)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    animate = true
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AudioManager.shared.playLetter(letter.isolated)
                }
                
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            
            VStack(spacing: 12) {
                Text(letter.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.noorText)
                
                Text(letter.transliteration)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.noorGold)
            }
            
            Spacer()
            Spacer()
        }
    }
}
