import SwiftUI

struct PracticeHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey("RÉVISIONS"))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.noorSecondary)
                    .tracking(2)
                
                Text(LocalizedStringKey("Centre d'entraînement"))
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.noorText)
            }
            Spacer()
        }
    }
}