import SwiftUI

struct LetterFormsStep: View {
    let letter: ArabicLetter
    
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
                FormRow(formType: .isolated, form: letter.isolated, stepNumber: 1)
                FormRow(formType: .initial, form: letter.initial, stepNumber: 2)
                FormRow(formType: .medial, form: letter.medial, stepNumber: 3)
                FormRow(formType: .final, form: letter.final, stepNumber: 4)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

struct FormRow: View {
    @Environment(\.colorScheme) var colorScheme
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
                Text(LocalizedStringKey(formType.rawValue))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.noorText)
                Text(LocalizedStringKey(formType.description))
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
