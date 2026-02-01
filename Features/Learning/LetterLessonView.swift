import SwiftUI

struct LetterLessonView: View {
    let letter: ArabicLetter
    let levelNumber: Int
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentStep = 0
    @State private var showCelebration = false
    @State private var completedForms: Set<LetterFormType> = []
    
    private let totalSteps = 6
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                LessonHeader(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    onClose: { presentationMode.wrappedValue.dismiss() }
                )
                
                ZStack {
                    switch currentStep {
                    case 0:
                        LetterPresentationStep(letter: letter)
                            .transition(.opacity)
                    case 1:
                        LetterFormsStep(letter: letter)
                            .transition(.opacity)
                    case 2:
                        FreeDrawingStep(
                            letter: letter,
                            formType: .isolated,
                            onComplete: { completeForm(.isolated) }
                        )
                        .transition(.opacity)
                    case 3:
                        FreeDrawingStep(
                            letter: letter,
                            formType: .initial,
                            onComplete: { completeForm(.initial) }
                        )
                        .transition(.opacity)
                    case 4:
                        FreeDrawingStep(
                            letter: letter,
                            formType: .medial,
                            onComplete: { completeForm(.medial) }
                        )
                        .transition(.opacity)
                    case 5:
                        FreeDrawingStep(
                            letter: letter,
                            formType: .final,
                            onComplete: { completeForm(.final) }
                        )
                        .transition(.opacity)
                    default:
                        EmptyView()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: currentStep)
                
                if currentStep < 2 {
                    HStack {
                        if currentStep > 0 {
                            Button(action: { withAnimation { currentStep -= 1 } }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.noorSecondary)
                                    .frame(width: 50, height: 50)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.05), radius: 5)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: { withAnimation { currentStep += 1 } }) {
                            HStack {
                                Text(LocalizedStringKey("Continuer"))
                                    .font(.system(size: 18, weight: .bold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 16)
                            .background(Color.noorGold)
                            .cornerRadius(30)
                            .shadow(color: .noorGold.opacity(0.3), radius: 8, y: 4)
                        }
                    }
                    .padding(24)
                }
            }
            
            if showCelebration {
                CelebrationOverlay(
                    onDismiss: { presentationMode.wrappedValue.dismiss() }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func completeForm(_ form: LetterFormType) {
        completedForms.insert(form)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                switch form {
                case .isolated: currentStep = 3
                case .initial: currentStep = 4
                case .medial: currentStep = 5
                case .final: completeLetter()
                }
            }
        }
    }
    
    private func completeLetter() {
        guard completedForms.count == 4 else {
            if !completedForms.contains(.isolated) { currentStep = 2 }
            else if !completedForms.contains(.initial) { currentStep = 3 }
            else if !completedForms.contains(.medial) { currentStep = 4 }
            else if !completedForms.contains(.final) { currentStep = 5 }
            return
        }
        
        dataManager.completeLetter(letterId: letter.id, inLevel: levelNumber)
        withAnimation {
            showCelebration = true
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
import SwiftUI

import Foundation

