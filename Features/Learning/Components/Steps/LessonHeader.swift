import SwiftUI

struct LessonHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.noorSecondary)
                        .frame(width: 36, height: 36)
                        .background(Color.noorSecondary.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.noorSecondary.opacity(0.2))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.noorGold, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(max(1, totalSteps)), height: 8)
                            .animation(.spring(response: 0.3), value: currentStep)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 20)
                
                Spacer()
                
                Text("\(currentStep + 1)/\(totalSteps)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.noorSecondary)
                    .frame(width: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
}
