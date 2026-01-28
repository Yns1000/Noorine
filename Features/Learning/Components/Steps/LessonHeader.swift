import SwiftUI

struct LessonHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let onClose: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.noorDark.opacity(0.8)))
            }
            .padding(.leading, 20)
            
            Spacer()
            
            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(index <= currentStep ? Color.noorGold : Color.white.opacity(0.2))
                        .frame(width: 30, height: 6)
                }
            }
            
            Spacer()
            
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.vertical, 16)
        .padding(.top, 40)
        .background(Color.noorDark)
    }
}
