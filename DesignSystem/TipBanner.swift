import SwiftUI

struct TipBanner: View {
    @Environment(\.colorScheme) var colorScheme
    let factKey: String
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.noorGold.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    StaticMascot(size: 32)
                        .frame(width: 32, height: 32)
                }
                .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey("Le savais-tu ?"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.noorGold)
                    
                    Text(LocalizedStringKey(factKey))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.noorText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer(minLength: 8)
                
                if onTap != nil {
                    Image(systemName: "arrow.2.circlepath")
                        .font(.system(size: 14))
                        .foregroundColor(.noorSecondary.opacity(0.5))
                        .padding(.top, 4)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
    }
}

struct StaticMascot: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.noorGold, Color.noorGold.opacity(0.6)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color.noorGold.opacity(0.5), radius: size * 0.25)
                .overlay(
                    Circle().stroke(Color.white.opacity(0.8), lineWidth: 2).padding(2)
                )
            
            HStack(spacing: size * 0.2) {
                Ellipse()
                    .frame(width: size * 0.075, height: size * 0.1)
                    .foregroundColor(Color.white.opacity(0.9))
                Ellipse()
                    .frame(width: size * 0.075, height: size * 0.1)
                    .foregroundColor(Color.white.opacity(0.9))
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

#Preview {
    ZStack {
        Color.noorBackground
        VStack(spacing: 40) {
            TipBanner(factKey: "L'arabe s'écrit de droite à gauche.")
                .padding()
            
            TipBanner(factKey: "Test avec aura visible", onTap: {})
                .padding()
        }
    }
}
