import SwiftUI
import SwiftData

/// Grid component for displaying photo list with local image loading in a masonry layout
struct PhotoGridView: View {
    @Environment(\.colorScheme) var colorScheme
    let photos: [Photo]
    var onAddMore: (() -> Void)? = nil
    
    @State private var selectedPhoto: Photo? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Column 1 (Left column, shorter thumbnails for staggered masonry height)
                VStack(spacing: 12) {
                    ForEach(leftColumnPhotos) { photo in
                        PhotoThumbnailView(photo: photo, height: 160)
                            .onTapGesture {
                                HapticService.lightImpact()
                                selectedPhoto = photo
                            }
                    }
                    
                    // Add More Button placed inline at the end of the left column
                    if let onAddMore = onAddMore {
                        Button(action: {
                            HapticService.mediumImpact()
                            onAddMore()
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.viewfinder")
                                    .font(.title2)
                                    .foregroundColor(.photoAccent)
                                Text("ADD PHOTOS")
                                    .font(.system(size: 10, weight: .bold, design: .serif))
                                    .tracking(1.0)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(
                                colorScheme == .dark ? Color.photoCardDark : Color.white
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.02), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(PhotoAddButtonStyle())
                    }
                }
                
                // Column 2 (Right column, taller thumbnails for masonry layout)
                VStack(spacing: 12) {
                    ForEach(rightColumnPhotos) { photo in
                        PhotoThumbnailView(photo: photo, height: 210)
                            .onTapGesture {
                                HapticService.lightImpact()
                                selectedPhoto = photo
                            }
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedPhoto) { photo in
            FullscreenPhotoViewer(photo: photo) {
                selectedPhoto = nil
            }
        }
    }
    
    private var leftColumnPhotos: [Photo] {
        var items: [Photo] = []
        for index in 0..<photos.count {
            if index % 2 == 0 {
                items.append(photos[index])
            }
        }
        return items
    }
    
    private var rightColumnPhotos: [Photo] {
        var items: [Photo] = []
        for index in 0..<photos.count {
            if index % 2 != 0 {
                items.append(photos[index])
            }
        }
        return items
    }
}

private struct PhotoAddButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.premiumSpring, value: configuration.isPressed)
    }
}

/// Fullscreen zoomable and swipe-to-dismiss photo viewer
struct FullscreenPhotoViewer: View {
    let photo: Photo
    let onClose: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var dragOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(dragOpacity)
                .ignoresSafeArea()
            
            if let uiImage = UIImage(contentsOfFile: StorageService.shared.getImageURL(path: photo.imagePath).path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation
                                let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                                dragOpacity = max(0.4, 1.0 - Double(distance / 500.0))
                            }
                            .onEnded { value in
                                let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                                if distance > 120 {
                                    withAnimation(.easeOut(duration: 0.22)) {
                                        onClose()
                                    }
                                } else {
                                    withAnimation(.premiumSpring) {
                                        offset = .zero
                                        dragOpacity = 1.0
                                    }
                                }
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                            .onEnded { value in
                                if scale < 1.0 {
                                    withAnimation(.premiumSpring) {
                                        scale = 1.0
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.premiumSpring) {
                            if scale > 1.0 {
                                scale = 1.0
                            } else {
                                scale = 2.2
                            }
                        }
                    }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 54))
                        .foregroundColor(.photoAccent.opacity(0.8))
                    
                    Text("FRAME NOT FOUND")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .tracking(1.5)
                        .foregroundColor(.white)
                    
                    Text("The local image file is missing or has been deleted from this device's storage.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 16)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.12, green: 0.12, blue: 0.12).opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 32)
            }
            
            // UI Overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        HapticService.lightImpact()
                        onClose()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.6))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
