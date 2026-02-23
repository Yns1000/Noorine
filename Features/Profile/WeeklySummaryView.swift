import SwiftUI

struct WeeklySummaryView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss

    @State private var showXP = false
    @State private var showDays = false
    @State private var showStreak = false
    @State private var showMessage = false
    @State private var showButton = false
    @State private var animatedXP: Int = 0

    private var isEnglish: Bool { languageManager.currentLanguage == .english }

    private var weekXP: Int { dataManager.getLastWeekXP() }
    private var activeDays: Int { dataManager.getLastWeekActiveDays() }
    private var dayActivity: [Bool] { dataManager.getLastWeekDayActivity() }
    private var streak: Int { dataManager.userProgress?.streakDays ?? 0 }
    private var letters: Int { dataManager.userProgress?.totalLettersMastered ?? 0 }

    private var dayLabels: [String] {
        if isEnglish {
            return ["M", "T", "W", "T", "F", "S", "S"]
        } else {
            return ["L", "M", "M", "J", "V", "S", "D"]
        }
    }

    private var encouragement: String {
        if activeDays >= 5 {
            return isEnglish ? "Incredible week!" : "Semaine incroyable !"
        } else if activeDays >= 3 {
            return isEnglish ? "Great job, keep going!" : "Bon travail, continue !"
        } else {
            return isEnglish ? "Every step counts!" : "Chaque pas compte !"
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.08, blue: 0.12), Color(red: 0.10, green: 0.14, blue: 0.22)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 20)

                    EmotionalMascot(mood: .celebrating, size: 80, showAura: false)

                    Text(isEnglish ? "Your Week" : "Ta semaine")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    if showXP {
                        VStack(spacing: 6) {
                            Text("\(animatedXP)")
                                .font(.system(size: 56, weight: .black, design: .rounded))
                                .foregroundColor(.noorGold)
                                .contentTransition(.numericText())
                            Text("XP")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.noorGold.opacity(0.7))
                        }
                        .transition(.scale.combined(with: .opacity))
                    }

                    if showDays {
                        VStack(spacing: 10) {
                            Text(isEnglish ? "Active days" : "Jours actifs")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))

                            HStack(spacing: 12) {
                                ForEach(0..<7, id: \.self) { i in
                                    VStack(spacing: 6) {
                                        Circle()
                                            .fill(dayActivity[i] ? Color.noorGold : Color.white.opacity(0.15))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                dayActivity[i]
                                                ? AnyView(Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundStyle(.black))
                                                : AnyView(EmptyView())
                                            )
                                        Text(dayLabels[i])
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if showStreak {
                        HStack(spacing: 12) {
                            VStack(spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(.orange)
                                    Text("\(streak)")
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                                Text(isEnglish ? "day streak" : "jours de suite")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                            VStack(spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "character.textbox")
                                        .foregroundColor(.noorGold)
                                    Text("\(letters)")
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                                Text(isEnglish ? "letters mastered" : "lettres maîtrisées")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if showMessage {
                        Text(encouragement)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.noorGold)
                            .multilineTextAlignment(.center)
                            .transition(.scale.combined(with: .opacity))
                    }

                    if showButton {
                        Button(action: {
                            dataManager.markWeeklySummarySeen()
                            dismiss()
                        }) {
                            Text(isEnglish ? "Continue" : "Continuer")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(Color.noorGold)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .onAppear { startAnimations() }
    }

    private func startAnimations() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
            showXP = true
        }
        animateXPCounter()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.8)) {
            showDays = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.3)) {
            showStreak = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.8)) {
            showMessage = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(2.3)) {
            showButton = true
        }
    }

    private func animateXPCounter() {
        let target = weekXP
        let steps = 20
        let interval = 0.8 / Double(steps)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * interval) {
                withAnimation(.easeOut(duration: interval)) {
                    animatedXP = Int(Double(target) * Double(i) / Double(steps))
                }
            }
        }
    }
}
