import SwiftUI

/// Elegant Floating Action Button (FAB) inspired by Things 3 and Halide
struct FloatingActionButton: View {
    @Environment(\.colorScheme) var colorScheme
    let action: () -> Void
    let systemImage: String
    
    var body: some View {
        Button(action: {
            HapticService.mediumImpact()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(Color.photoAccent)
                    .frame(width: 58, height: 58)
                    .shadow(color: Color.photoAccent.opacity(0.35), radius: 10, x: 0, y: 5)
                
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
        }
        .buttonStyle(FABButtonStyle())
    }
}

private struct FABButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.premiumSpring, value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.photoBackgroundDark
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingActionButton(action: {}, systemImage: "plus")
                    .padding()
            }
        }
    }
}
