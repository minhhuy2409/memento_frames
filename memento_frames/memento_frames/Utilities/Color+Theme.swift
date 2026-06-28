import SwiftUI

extension Color {
    /// Premium Warm Gold/Amber - reminiscent of vintage film chemistry and brass camera bodies
    static let photoAccent = Color(red: 0.78, green: 0.68, blue: 0.53) // Premium Warm Beige/Brass
    
    /// Classic Camera/Leica red for highlight alerts, recording status, and bold details
    static let photoRed = Color(red: 0.83, green: 0.18, blue: 0.18)
    
    /// Warm, clean white/cream for a printed journal aesthetic in light mode
    static let photoBackgroundLight = Color(red: 0.98, green: 0.98, blue: 0.96)
    
    /// True matte black for darkroom and night shoot vibe in dark mode
    static let photoBackgroundDark = Color(red: 0.07, green: 0.07, blue: 0.07)
    
    /// Soft, subtle gray/brown for borders and dividers
    static let photoBorderLight = Color(red: 0.90, green: 0.89, blue: 0.86)
    static let photoBorderDark = Color(red: 0.18, green: 0.18, blue: 0.18)
    
    /// Background color for cards and secondary layers
    static let photoCardLight = Color.white
    static let photoCardDark = Color(red: 0.12, green: 0.12, blue: 0.12)
}

struct PhotoThemeModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .tint(.photoAccent)
            .accentColor(.photoAccent)
    }
}

struct ShimmerModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    let highlightColor = colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.05)
                    LinearGradient(
                        colors: [.clear, highlightColor, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width)
                    .offset(x: -geometry.size.width + (phase * geometry.size.width * 2))
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
            .clipped()
    }
}

extension View {
    func applyPhotoTheme() -> some View {
        self.modifier(PhotoThemeModifier())
    }
    
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

extension Animation {
    static var premiumSpring: Animation {
        .spring(response: 0.42, dampingFraction: 0.82, blendDuration: 0)
    }
}

