import SwiftUI

extension Color {    
    static let noorGold = Color(red: 1.0, green: 0.84, blue: 0.40)
    static let noorGoldDark = Color(red: 0.92, green: 0.72, blue: 0.25)
    static let noorDark = Color(red: 0.08, green: 0.12, blue: 0.18)
    
    static var noorBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1) 
                : UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1)
        })
    }
    
    static var noorText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(red: 0.95, green: 0.90, blue: 0.80, alpha: 1) 
                : UIColor(red: 0.08, green: 0.12, blue: 0.18, alpha: 1)
        })
    }
    
    static var noorSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(red: 0.6, green: 0.65, blue: 0.7, alpha: 1) 
                : UIColor(red: 0.55, green: 0.58, blue: 0.62, alpha: 1)
        })
    }
        
    static let noorSuccess = Color(red: 0.35, green: 0.78, blue: 0.55)
    static let noorWarning = Color(red: 1.0, green: 0.65, blue: 0.35)
    static let noorError = Color(red: 0.95, green: 0.40, blue: 0.45)
}


extension LinearGradient {
    static var noorGoldGradient: LinearGradient {
        LinearGradient(
            colors: [Color.noorGold, Color.noorGoldDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var noorMysticGradient: LinearGradient {
        LinearGradient(
            colors: [Color.noorDark, Color.noorDark.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct TapScaleModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

struct ShakeModifier: ViewModifier {
    var trigger: Bool
    @State private var shakeOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: trigger) { _, _ in
                withAnimation(.linear(duration: 0.06)) { shakeOffset = -8 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                    withAnimation(.linear(duration: 0.06)) { shakeOffset = 8 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.linear(duration: 0.06)) { shakeOffset = -4 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.linear(duration: 0.06)) { shakeOffset = 4 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) { shakeOffset = 0 }
                }
            }
    }
}

struct PulseModifier: ViewModifier {
    var trigger: Bool
    var color: Color = .noorSuccess
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(pulseOpacity * 0.15))
                    .scaleEffect(pulseScale)
            )
            .scaleEffect(pulseScale)
            .onChange(of: trigger) { _, _ in
                withAnimation(.easeOut(duration: 0.15)) {
                    pulseScale = 1.08
                    pulseOpacity = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        pulseScale = 1.0
                        pulseOpacity = 0
                    }
                }
            }
    }
}

extension View {
    func tapScale() -> some View {
        modifier(TapScaleModifier())
    }

    func shake(trigger: Bool) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }

    func pulse(trigger: Bool, color: Color = .noorSuccess) -> some View {
        modifier(PulseModifier(trigger: trigger, color: color))
    }
}
