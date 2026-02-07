import SwiftUI

struct LetterLessonView: View {
    let letter: ArabicLetter
    let levelNumber: Int
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentStep = 0
    @State private var showCelebration = false
    @State private var completedForms: Set<LetterFormType> = []
    
Ameliore la card des annecdotes pour qu'elle puisse prendre plus de hauteur si le texte est trop long pcq sinon ça met des ... et faut pas que sa mascotte saute quand elle apparait 

Pour sukkun shadda et tanwin bah le tts foire des fois on entend mal donc jsp mais trouve un concept innovant pour mieux faire ces niveaux et dans les quizz des fois on voit pas entierement les lettres 

y'a un soucis sur certains mot qui finissent par ha comme ciel samaa regarde la capture d'ecran  et augmente la taille des mots dans la creation de la phrase fin le build the phrase    private var availableForms: [LetterFormType] {
        LetterFormType.availableForms(for: letter.id)
    }
    
    private var totalSteps: Int {
        2 + availableForms.count
    }
    
    var body: some View {
        ZStack {
            Color.noorBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                LessonHeader(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    onClose: {
                        logLetterMistakeOnQuit()
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                
                ZStack {
                    if currentStep == 0 {
                        LetterPresentationStep(letter: letter)
                            .transition(.opacity)
                    } else if currentStep == 1 {
                        LetterFormsStep(letter: letter)
                            .transition(.opacity)
                    } else {
                        let formIndex = currentStep - 2
                        if formIndex < availableForms.count {
                            let formType = availableForms[formIndex]
                            FreeDrawingStep(
                                letter: letter,
                                formType: formType,
                                onComplete: { completeForm(formType) }
                            )
                            .transition(.opacity)
                            .id("drawing-\(formType.rawValue)")
                        } else {
                            EmptyView()
                        }
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
        .onDisappear {
            logLetterMistakeOnQuit()
        }
    }

    private func logLetterMistakeOnQuit() {
        guard !showCelebration else { return }
        let incompleteFormTypes = availableForms.filter { !completedForms.contains($0) }
        for formType in incompleteFormTypes {
            dataManager.addMistake(itemId: String(letter.id), type: "letter", formType: formType.rawValue)
        }
    }

    private func completeForm(_ form: LetterFormType) {
        completedForms.insert(form)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                if currentStep < totalSteps - 1 {
                    currentStep += 1
                } else {
                    completeLetter()
                }
            }
        }
    }
    
    private func completeLetter() {
        guard completedForms.count == availableForms.count else {
            if let firstIncompleteIndex = availableForms.firstIndex(where: { !completedForms.contains($0) }) {
                currentStep = 2 + firstIncompleteIndex
            }
            return
        }
        
        dataManager.completeLetter(letterId: letter.id, inLevel: levelNumber)
        withAnimation {
            showCelebration = true
        }
        FeedbackManager.shared.success()
    }
}
import SwiftUI

import Foundation
