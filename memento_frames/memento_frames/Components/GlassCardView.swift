import SwiftUI

/// A container card that uses .ultraThinMaterial (glassmorphic layout card)
struct GlassCardView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    colorScheme == .dark 
                        ? Color.white.opacity(0.1) 
                        : Color.black.opacity(0.06), 
                    lineWidth: 1
                )
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.05),
            radius: 10,
            x: 0,
            y: 5
        )
    }
}

#Preview {
    ZStack {
        Color.photoBackgroundDark
            .ignoresSafeArea()
        
        GlassCardView {
            VStack(spacing: 8) {
                Text("Glassmorphic Layer")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Inspired by Halide and Apple UI elements.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .padding()
    }
}
