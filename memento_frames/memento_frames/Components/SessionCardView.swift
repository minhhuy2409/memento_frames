import SwiftUI
import SwiftData

/// Session card component for displaying session preview with cover image
struct SessionCardView: View {
    @Environment(\.colorScheme) var colorScheme
    let session: Session
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Cover Photo or placeholder gradient
            if let path = session.coverPhotoPath,
               let uiImage = UIImage(contentsOfFile: StorageService.shared.getImageURL(path: path).path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                LinearGradient(
                    colors: [
                        colorScheme == .dark ? Color.photoCardDark : Color.white,
                        colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .overlay(
                    Image(systemName: "camera")
                        .font(.system(size: 34))
                        .foregroundColor(.photoAccent.opacity(0.35))
                )
            }
            
            // Bottom shadow overlay for typography readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.35), .black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
            
            // Text Details overlaid at the bottom
            VStack(alignment: .leading, spacing: 6) {
                Text(session.title)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(alignment: .bottom) {
                    if !session.location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.photoAccent)
                            Text(session.location)
                        }
                    }
                    
                    Spacer()
                    
                    Text(session.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            }
            .padding(18)
        }
        .frame(height: 220)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    colorScheme == .dark 
                        ? Color.white.opacity(0.08) 
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
    SessionCardView(session: Session(
        title: "Sunset Street Walks",
        date: Date(),
        location: "Hanoi, Vietnam",
        camera: Camera(brand: "Leica", model: "M11")
    ))
    .padding()
    .background(Color.photoBackgroundDark)
}
