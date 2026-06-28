import SwiftUI

/// Premium photo grid thumbnail with loading skeleton shimmer and soft shadow
struct PhotoThumbnailView: View {
    @Environment(\.colorScheme) var colorScheme
    let photo: Photo
    let height: CGFloat
    
    @State private var uiImage: UIImage? = nil
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                // Loading skeleton with shimmer
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color.photoCardDark : Color.photoBorderLight)
                    .frame(height: height)
                    .shimmer()
            }
            
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.05), radius: 6, x: 0, y: 3)
            } else if !isLoading {
                // Failure placeholder
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color.photoCardDark : Color.photoBorderLight)
                    .frame(height: height)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title3)
                            .foregroundColor(.photoAccent.opacity(0.4))
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let path = photo.imagePath
        
        // 1. Check memory cache first
        if let cached = ImageCacheService.shared.image(forKey: path) {
            self.uiImage = cached
            self.isLoading = false
            return
        }
        
        // 2. Load in background to prevent UI lag on scroll
        DispatchQueue.global(qos: .userInitiated).async {
            let url = StorageService.shared.getImageURL(path: path)
            if let image = UIImage(contentsOfFile: url.path) {
                // Cache the loaded thumbnail
                ImageCacheService.shared.setImage(image, forKey: path)
                
                DispatchQueue.main.async {
                    self.uiImage = image
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    PhotoThumbnailView(photo: Photo(imagePath: "mock.jpg"), height: 120)
        .padding()
        .background(Color.photoBackgroundDark)
}
