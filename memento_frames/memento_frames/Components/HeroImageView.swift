import SwiftUI

/// Stretchable parallax hero image header for details pages
struct HeroImageView: View {
    let imagePath: String?
    let height: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .global).minY
            let isScrollDown = minY > 0
            
            ZStack(alignment: .bottom) {
                if let path = imagePath,
                   let uiImage = UIImage(contentsOfFile: StorageService.shared.getImageURL(path: path).path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: isScrollDown ? height + minY : height
                        )
                        .clipped()
                        .offset(y: isScrollDown ? -minY : 0)
                } else {
                    // Placeholder gradient
                    LinearGradient(
                        colors: [
                            Color.photoCardDark.opacity(0.8),
                            Color.photoBackgroundDark
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(
                        width: geometry.size.width,
                        height: isScrollDown ? height + minY : height
                    )
                    .offset(y: isScrollDown ? -minY : 0)
                    .overlay(
                        Image(systemName: "camera")
                            .font(.system(size: 38))
                            .foregroundColor(.photoAccent.opacity(0.3))
                            .offset(y: isScrollDown ? -minY / 2 : 0)
                    )
                }
                
                // Bottom fade gradient
                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(
                    width: geometry.size.width,
                    height: isScrollDown ? height + minY : height
                )
                .offset(y: isScrollDown ? -minY : 0)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    ScrollView {
        VStack {
            HeroImageView(imagePath: nil, height: 280)
            
            VStack {
                ForEach(0..<10) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 100)
                        .padding()
                }
            }
        }
    }
    .background(Color.photoBackgroundDark)
}
