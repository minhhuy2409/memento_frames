import SwiftUI

/// Poetic and minimal empty state view using materials and premium styling
struct EmptyStateView: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let description: String
    let action: (() -> Void)?
    let actionLabel: String?
    
    init(
        icon: String = "photo",
        title: String,
        description: String,
        action: (() -> Void)? = nil,
        actionLabel: String? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.action = action
        self.actionLabel = actionLabel
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon capsule
            ZStack {
                Circle()
                    .fill(Color.photoAccent.opacity(colorScheme == .dark ? 0.08 : 0.05))
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.photoAccent)
            }
            .padding(.bottom, 8)
            
            // Text Details
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
            }
            
            // Action button (Things 3 / Halide style)
            if let action = action, let actionLabel = actionLabel {
                Button(action: {
                    HapticService.lightImpact()
                    action()
                }) {
                    Text(actionLabel)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Color.photoAccent)
                        .cornerRadius(24)
                        .shadow(color: Color.photoAccent.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(EmptyStateButtonStyle())
                .padding(.top, 12)
            }
        }
        .padding(32)
        .background(
            GlassCardView {
                Color.clear
            }
        )
        .padding(.horizontal, 24)
    }
}

private struct EmptyStateButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.premiumSpring, value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.photoBackgroundDark
            .ignoresSafeArea()
        
        EmptyStateView(
            icon: "camera.shutter.button",
            title: "Begin Your Story",
            description: "Import frames and keep notes on your analog film and lens profiles to create a journal.",
            action: {},
            actionLabel: "Create Session"
        )
    }
}
