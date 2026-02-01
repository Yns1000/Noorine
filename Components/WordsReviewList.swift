import SwiftUI

struct WordsReviewList: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(LocalizedStringKey("À revoir bientôt"))
                    .font(.headline)
                    .foregroundColor(.noorText)
                
                Spacer()
                
                Button("Tout voir") { }
                    .font(.caption)
                    .foregroundColor(.noorGold)
            }
            
            VStack(spacing: 0) {
                ReviewRow(arabic: "كِتَاب", phonetic: "Kitāb", translation: "Livre", strength: 0.3)
                Divider().padding(.leading, 60)
                ReviewRow(arabic: "قَلَم", phonetic: "Qalam", translation: "Stylo", strength: 0.5)
                Divider().padding(.leading, 60)
                ReviewRow(arabic: "مَدْرَسَة", phonetic: "Madrasa", translation: "École", strength: 0.8)
            }
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
        }
    }
}

struct ReviewRow: View {
    let arabic: String
    let phonetic: String
    let translation: String
    let strength: Double
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .stroke(Color.noorSecondary.opacity(0.2), lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: strength)
                    .stroke(strengthColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                
                Text(arabic)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.noorText)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(translation)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.noorText)
                
                Text(phonetic)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.noorSecondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "speaker.wave.2.circle.fill")
                    .font(.title2)
                    .foregroundColor(.noorSecondary.opacity(0.5))
            }
        }
        .padding(16)
    }
    
    var strengthColor: Color {
        if strength < 0.4 { return .red }
        if strength < 0.7 { return .orange }
        return .green
    }
}