import SwiftUI

struct LetterFormsStep: View {
    let letter: ArabicLetter
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(spacing: 30) {
            Text(LocalizedStringKey("Les 4 formes"))
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(.noorText)
                .padding(.top, 30)
            
            Text(LocalizedStringKey("Tu vas maintenant les tracer une par une !"))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.noorSecondary)
            
            VStack(spacing: 16) {
                ForEach(Array(LetterFormType.availableForms(for: letter.id).enumerated()), id: \.element) { index, formType in
                    FormRow(
                        formType: formType,
                        form: formType.getForm(from: letter),
                        stepNumber: index + 1
                    )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

struct FormRow: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    let formType: LetterFormType
    let form: String
    let stepNumber: Int
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.noorGold.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text("\(stepNumber)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.noorGold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formType.localizedName(language: languageManager.currentLanguage))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.noorText)
                Text(formType.localizedDescription(language: languageManager.currentLanguage))
                    .font(.system(size: 12))
                    .foregroundColor(.noorSecondary)
            }
            
            Spacer()
            
            Text(form)
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(.noorGold)
                .frame(width: 80)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
}
