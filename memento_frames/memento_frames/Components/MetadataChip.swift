import SwiftUI

/// Pill-shaped capsule tag displaying photo metadata or stats in a monospaced font
struct MetadataChip: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.photoAccent)
            
            Text(text)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(colorScheme == .dark ? Color.photoCardDark : Color.white)
        )
        .overlay(
            Capsule()
                .stroke(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.15 : 0.02), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HStack(spacing: 8) {
        MetadataChip(icon: "camera.fill", text: "FUJIFILM X-T5")
        MetadataChip(icon: "film.fill", text: "PORTRA 400")
        MetadataChip(icon: "timer", text: "1/250s")
    }
    .padding()
    .background(Color.photoBackgroundDark)
}
