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
                                Text("Continuer")
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
                            .frame(width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps), height: 8)
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
import SwiftUI

struct LetterPresentationStep: View {
    let letter: ArabicLetter
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.noorGold.opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(animate ? 1.1 : 1.0)
                
                Text(letter.isolated)
                    .font(.system(size: 120, weight: .medium))
                    .foregroundColor(.noorText)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            
            VStack(spacing: 12) {
                Text(letter.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.noorText)
                
                Text(letter.transliteration)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.noorGold)
            }
            
            Spacer()
            Spacer()
        }
    }
}
import SwiftUI

struct LetterFormsStep: View {
    let letter: ArabicLetter
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Les 4 formes")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(.noorText)
                .padding(.top, 30)
            
            Text("Tu vas maintenant les tracer une par une !")
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
                Text(formType.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.noorText)
                Text(formType.description)
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
import SwiftUI

struct CelebrationOverlay: View {
    let onDismiss: () -> Void
    var onNext: (() -> Void)? = nil
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var showStars = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            if showStars {
                ForEach(0..<8, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.noorGold.opacity(0.6))
                        .offset(
                            x: CGFloat.random(in: -120...120),
                            y: CGFloat.random(in: -200...(-50))
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            VStack(spacing: 24) {
                Image(systemName: "star.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.noorGold)
                
                Text("Bravo !")
                    .font(.system(size: 36, weight: .black, design: .serif))
                    .foregroundColor(.white)
                
                Text("Tu as maîtrisé les 4 formes !")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("+10 XP")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.noorGold)
                
                VStack(spacing: 16) {
                    if let onNext = onNext {
                        Button(action: onNext) {
                            HStack {
                                Text("Lettre Suivante")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.noorDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.noorGold)
                            .cornerRadius(30)
                        }
                    }
                    
                    Button(action: onDismiss) {
                        Text(onNext == nil ? "Terminer" : "Menu Principal")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4)) {
                    showStars = true
                }
            }
        }
    }
}
import Foundation

enum LetterFormType: String, CaseIterable {
    case isolated = "Isolée"
    case initial = "Initiale"
    case medial = "Médiane"
    case final = "Finale"
    
    var description: String {
        switch self {
        case .isolated: return "Seule"
        case .initial: return "Début de mot"
        case .medial: return "Milieu de mot"
        case .final: return "Fin de mot"
        }
    }
    
    func getForm(from letter: ArabicLetter) -> String {
        switch self {
        case .isolated: return letter.isolated
        case .initial: return letter.initial
        case .medial: return letter.medial
        case .final: return letter.final
        }
    }
}
