import SwiftUI

struct PronunciationLibraryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    let onSelect: (ArabicLetter) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.noorBackground.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(ArabicLetter.alphabet) { letter in
                            Button(action: { onSelect(letter) }) {
                                HStack(spacing: 16) {
                                    Text(letter.isolated)
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.noorGold)
                                        .frame(width: 60)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(letter.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.noorText)
                                        
                                        Text(letter.transliteration)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.noorSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        AudioManager.shared.playLetter(letter.isolated)
                                    }) {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.purple)
                                            .padding(10)
                                            .background(Circle().fill(Color.purple.opacity(0.1)))
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.noorSecondary.opacity(0.5))
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(colorScheme == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color.white)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(LocalizedStringKey("Toutes les lettres"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.noorSecondary.opacity(0.6))
                    }
                }
            }
        }
    }
}