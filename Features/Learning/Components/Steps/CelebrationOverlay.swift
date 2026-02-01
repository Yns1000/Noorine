import SwiftUI

struct CelebrationOverlay: View {
    let onDismiss: () -> Void
    var onNext: (() -> Void)? = nil
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var showStars = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            if showStars {
                ForEach(0..<8, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.noorGold.opacity(0.6))
                        .offset(
                            x: CGFloat.random(in: -120...120),
                            y: CGFloat.random(in: -200...(-50))
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            VStack(spacing: 24) {
                Image(systemName: "star.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.noorGold)
                
                Text(LocalizedStringKey("Bravo !"))
                    .font(.system(size: 36, weight: .black, design: .serif))
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey("Tu as maîtrisé les 4 formes !"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("+10 XP")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.noorGold)
                
                VStack(spacing: 16) {
                    if let onNext = onNext {
                        Button(action: onNext) {
                            HStack {
                                Text(LocalizedStringKey("Lettre Suivante"))
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.noorDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.noorGold)
                            .cornerRadius(30)
                        }
                    }
                    
                        Button(action: onDismiss) {
                            Text(onNext == nil ? LocalizedStringKey("Terminer") : LocalizedStringKey("Menu Principal"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4)) {
                    showStars = true
                }
            }
        }
    }
}
