import SwiftUI

struct TipBanner: View {
    @Environment(\.colorScheme) var colorScheme
    let factKey: String
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: 16) {
                ZStack {

                    Circle()
                        .fill(Color.noorGold.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    EmotionalMascot(mood: .happy, size: 32, showAura: true)
                        .frame(width: 32, height: 32)
                }
                .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey("Le savais-tu ?"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.noorGold)
                    
                    Text(LocalizedStringKey(factKey))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.noorText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if onTap != nil {
                    Image(systemName: "arrow.2.circlepath")
                        .font(.system(size: 14))
                        .foregroundColor(.noorSecondary.opacity(0.5))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
            .cornerRadius(20)
            .zIndex(1)
            .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
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
