import SwiftUI
import ActivityKit

struct LetterLessonView: View {
    let letter: ArabicLetter
    let levelNumber: Int
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentStep = 0
    @State private var showCelebration = false
    @State private var completedForms: Set<LetterFormType> = []
    
    private var isEnglish: Bool {
        languageManager.currentLanguage == .english
    }
    
    private var availableForms: [LetterFormType] {
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
                        endLiveActivity(xp: 0)
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
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.05), radius: 5)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: { withAnimation { currentStep += 1 } }) {
                            HStack {
                                Text(LocalizedStringKey(isEnglish ? "Continue" : "Continuer"))
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
        .onAppear {
            startLiveActivity()
        }
        .onChange(of: currentStep) { _, newStep in
            updateLiveActivity(step: newStep)
        }
        .onDisappear {
            logLetterMistakeOnQuit()
            if !showCelebration {
                cancelLiveActivity()
            }
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
        endLiveActivity(xp: 10)
        withAnimation {
            showCelebration = true
        }
        FeedbackManager.shared.success()
    }

    private func startLiveActivity() {
        if #available(iOS 16.2, *) {
            LiveActivityManager.shared.startLessonActivity(
                levelNumber: levelNumber,
                totalItems: totalSteps,
                lessonTitle: letter.name
            )
        }
    }

    private func updateLiveActivity(step: Int) {
        if #available(iOS 16.2, *) {
            let progress = Double(step) / Double(max(totalSteps - 1, 1))
            let formIndex = max(0, step - 2)
            let currentFormName = formIndex < availableForms.count
                ? availableForms[formIndex].rawValue
                : letter.name

            LiveActivityManager.shared.updateProgress(
                letterName: currentFormName,
                letterArabic: letter.isolated,
                progress: progress,
                xpEarned: step * 3,
                lessonTitle: letter.name
            )
        }
    }

    private func endLiveActivity(xp: Int) {
        if #available(iOS 16.2, *) {
            LiveActivityManager.shared.endLessonActivity(xpEarned: xp)
        }
    }

    private func cancelLiveActivity() {
        if #available(iOS 16.2, *) {
            LiveActivityManager.shared.cancelActivity()
        }
    }
}
import SwiftUI

import Foundation
