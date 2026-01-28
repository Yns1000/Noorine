import SwiftUI

struct NoorineMascot: View {
    @State private var isBlinking = false
    @State private var auraRotation = 0.0
    
    var body: some View {
        ZStack {
            // 1. L'Aura mystique (qui tourne)
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [.noorGold.opacity(0), .noorGold.opacity(0.5), .noorGold.opacity(0)]),
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 260, height: 260)
                .rotationEffect(.degrees(auraRotation))
            
            // 2. Le Visage Solaire
            ZStack {
                // Le fond dégradé
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.noorGold, .orange.opacity(0.5)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 70
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .noorGold.opacity(0.6), radius: 35)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.7), lineWidth: 1).padding(2)
                    )
                
                // Les traits du visage
                Group {
                    // Les yeux
                    HStack(spacing: 16) {
                        Ellipse().frame(width: 6, height: 8)
                        Ellipse().frame(width: 6, height: 8)
                    }
                    .foregroundColor(Color.white.opacity(0.9))
                    .scaleEffect(y: isBlinking ? 0.1 : 1.0)
                    .offset(y: -10)
                    
                    // Le sourire
                    Circle()
                        .trim(from: 0.1, to: 0.4)
                        .stroke(Color.white.opacity(0.8), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 35, height: 35)
                        .offset(y: 2)
                    
                    // Le grain de beauté (Couleur Ambre)
                    Circle()
                        .fill(Color(red: 0.8, green: 0.4, blue: 0.1).opacity(0.6))
                        .frame(width: 4, height: 4)
                        .offset(x: -18, y: 2)
                }
            }
        }
        .onAppear {
            // Lancer la rotation
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                auraRotation = 360
            }
            // Lancer le clignement
            startBlinking()
        }
    }
    
    private func startBlinking() {
        let randomInterval = Double.random(in: 2.0...4.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomInterval) {
            // Ferme les yeux
            withAnimation(.easeInOut(duration: 0.15)) {
                isBlinking = true
            }
            
            // Rouvre les yeux après 0.15s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isBlinking = false
                }
                // Relance la boucle
                startBlinking()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.noorBackground.ignoresSafeArea()
        NoorineMascot()
    }
}
