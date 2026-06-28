import SwiftUI

/// Metadata badge component with premium visual style
struct MetadataBadge: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.photoAccent)
            
            Text(text)
                .font(.system(size: 11, weight: .medium, design: .serif))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            colorScheme == .dark ? Color.photoCardDark : Color.photoCardLight
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 3, x: 0, y: 1)
    }
}

/// Section header component with elegant serif style and uppercase tracking
struct SectionHeader: View {
    let title: String
    let icon: String?
    
    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.photoAccent)
            }
            Text(title.uppercased())
                .font(.system(size: 13, weight: .bold, design: .serif))
                .tracking(1.8)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

/// Form input field with elegant card layers and borders
struct FormField: View {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    @Binding var text: String
    let placeholder: String
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold, design: .serif))
                .tracking(1.2)
                .foregroundColor(.secondary)
            
            if isMultiline {
                TextEditor(text: $text)
                    .frame(height: 120)
                    .padding(10)
                    .scrollContentBackground(.hidden) // hidden so background modifier works
                    .background(colorScheme == .dark ? Color.photoCardDark : Color.photoCardLight)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight, lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .padding(12)
                    .background(colorScheme == .dark ? Color.photoCardDark : Color.photoCardLight)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight, lineWidth: 1)
                    )
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MetadataBadge(icon: "camera.fill", text: "Canon R5")
        SectionHeader("Photos", icon: "photo.fill")
        FormField(label: "Title", text: .constant(""), placeholder: "Enter title")
    }
    .padding()
    .background(Color.photoBackgroundDark)
}
