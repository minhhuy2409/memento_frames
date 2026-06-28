import SwiftUI
import SwiftData
import PhotosUI

/// Detail view for a photography session with parallax headers and glassmorphic detail elements
struct SessionDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    let session: Session
    @StateObject private var viewModel: SessionDetailViewModel
    @State private var showPhotosPicker = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isProcessingPhotos = false
    @State private var showEditSheet = false
    
    @MainActor
    init(session: Session, modelContext: ModelContext? = nil) {
        self.session = session
        let context = modelContext ?? .preview
        _viewModel = StateObject(wrappedValue: SessionDetailViewModel(session: session, modelContext: context))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Theme Background
            (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Parallax stretch header
                    HeroImageView(imagePath: session.coverPhotoPath, height: 260)
                    
                    VStack(alignment: .leading, spacing: 22) {
                        // Title Header overlaid card
                        GlassCardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(session.title)
                                    .font(.system(size: 26, weight: .bold, design: .serif))
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 12) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.photoAccent)
                                            .font(.caption)
                                        Text(session.date.formatted(date: .abbreviated, time: .omitted))
                                    }
                                    .font(.system(size: 11, weight: .semibold, design: .serif))
                                    .foregroundColor(.secondary)
                                    
                                    if !session.location.isEmpty {
                                        HStack(spacing: 4) {
                                            Image(systemName: "mappin.circle.fill")
                                                .foregroundColor(.photoAccent)
                                                .font(.caption)
                                            Text(session.location)
                                        }
                                        .font(.system(size: 11, weight: .semibold, design: .serif))
                                        .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(18)
                        }
                        
                        // 2. Journal Notes section (Story first!)
                        if !session.note.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionHeader("STORY NOTES", icon: "note.text")
                                
                                GlassCardView {
                                    Text(session.note)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .lineSpacing(6)
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        
                        // 3. Captured Photos Grid
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                SectionHeader("CAPTURED PHOTOS", icon: "photo.fill")
                                Spacer()
                                Text("\(session.photoCount) IMAGES")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .tracking(1.0)
                            }
                            
                            if session.photos.isEmpty {
                                Button(action: {
                                    HapticService.lightImpact()
                                    showPhotosPicker = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle")
                                            .font(.system(size: 14, weight: .bold))
                                        Text("IMPORT PHOTO FRAMES")
                                            .font(.system(size: 12, weight: .bold, design: .serif))
                                            .tracking(1.0)
                                    }
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(14)
                                    .background(Color.photoAccent)
                                    .cornerRadius(16)
                                    .shadow(color: Color.photoAccent.opacity(0.35), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(ScaleButtonStyle())
                                .padding(.top, 8)
                            } else {
                                PhotoGridView(photos: session.photos, onAddMore: {
                                    showPhotosPicker = true
                                })
                            }
                        }
                        
                        // 4. Geotag map block shortcut
                        if !viewModel.geotaggedPhotos.isEmpty {
                            NavigationLink(destination: PhotoMapView(photos: viewModel.geotaggedPhotos)) {
                                GlassCardView {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.photoAccent.opacity(0.1))
                                                .frame(width: 40, height: 40)
                                            
                                            Image(systemName: "map.fill")
                                                .foregroundColor(.photoAccent)
                                                .font(.subheadline)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("GEOTAG MAP")
                                                .font(.system(size: 11, weight: .bold, design: .serif))
                                                .tracking(1.0)
                                                .foregroundColor(.primary)
                                            Text("\(viewModel.geotaggedPhotos.count) frames mapped with GPS coordinates")
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.photoAccent)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .padding(14)
                                }
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        
                        // 5. Technical Parameters (EXIF metrics summary)
                        let isos = session.photos.compactMap { $0.iso }
                        let apertures = session.photos.compactMap { $0.aperture }
                        let focalLengths = session.photos.compactMap { $0.focalLength }
                        
                        if !isos.isEmpty || !apertures.isEmpty || !focalLengths.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionHeader("TECHNICAL PARAMETERS", icon: "slider.horizontal.3")
                                
                                GlassCardView {
                                    Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
                                        if !isos.isEmpty {
                                            let minISO = isos.min()!
                                            let maxISO = isos.max()!
                                            let isoText = minISO == maxISO ? "\(minISO)" : "\(minISO) – \(maxISO)"
                                            GridRow {
                                                Text("ISO RANGE")
                                                    .font(.system(size: 9, weight: .bold, design: .serif))
                                                    .foregroundColor(.secondary)
                                                    .tracking(1.0)
                                                Text(isoText)
                                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                            }
                                        }
                                        
                                        if !apertures.isEmpty {
                                            let cleanAps = apertures.compactMap { Double($0) }
                                            if !cleanAps.isEmpty {
                                                let minAp = cleanAps.min()!
                                                let maxAp = cleanAps.max()!
                                                let apText = minAp == maxAp ? "f/\(minAp)" : "f/\(minAp) – f/\(maxAp)"
                                                GridRow {
                                                    Text("APERTURE")
                                                        .font(.system(size: 9, weight: .bold, design: .serif))
                                                        .foregroundColor(.secondary)
                                                        .tracking(1.0)
                                                    Text(apText)
                                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                                }
                                            }
                                        }
                                        
                                        if !focalLengths.isEmpty {
                                            let cleanFLs = focalLengths.compactMap { Int($0) }
                                            if !cleanFLs.isEmpty {
                                                let minFL = cleanFLs.min()!
                                                let maxFL = cleanFLs.max()!
                                                let flText = minFL == maxFL ? "\(minFL)mm" : "\(minFL)mm – \(maxFL)mm"
                                                GridRow {
                                                    Text("FOCAL RANGE")
                                                        .font(.system(size: 9, weight: .bold, design: .serif))
                                                        .foregroundColor(.secondary)
                                                        .tracking(1.0)
                                                    Text(flText)
                                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                                }
                                            }
                                        }
                                    }
                                    .padding(16)
                                }
                            }
                        }
                        
                        // 6. Gear assigned (optional)
                        if session.camera != nil || session.lens != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionHeader("GEAR PROFILE", icon: "camera.fill")
                                
                                GlassCardView {
                                    VStack(alignment: .leading, spacing: 12) {
                                        if let camera = session.camera {
                                            HStack(spacing: 8) {
                                                Image(systemName: "camera.fill")
                                                    .foregroundColor(.photoAccent)
                                                    .font(.system(size: 12))
                                                    .frame(width: 16)
                                                Text("Camera:")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                Text(camera.displayName)
                                                    .font(.system(size: 13, weight: .bold, design: .serif))
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        
                                        if session.camera != nil && session.lens != nil {
                                            Divider()
                                                .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                                        }
                                        
                                        if let lens = session.lens {
                                            HStack(spacing: 8) {
                                                Image(systemName: "camera.macro")
                                                    .foregroundColor(.photoAccent)
                                                    .font(.system(size: 12))
                                                    .frame(width: 16)
                                                Text("Lens:")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                Text(lens.displayName)
                                                    .font(.system(size: 13, weight: .bold, design: .serif))
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                    }
                                    .padding(16)
                                }
                            }
                        }
                        
                        // 7. Film details (optional)
                        if let film = session.filmRoll, UserDefaults.standard.bool(forKey: "isFilmModeEnabled") {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionHeader("FILM STOCK", icon: "film.fill")
                                
                                GlassCardView {
                                    HStack(spacing: 12) {
                                        Image(systemName: "film.fill")
                                            .foregroundColor(.photoAccent)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(film.name)
                                                .font(.system(size: 14, weight: .bold, design: .serif))
                                            Text("ISO \(film.iso) • Frame count: \(film.currentFrame)/\(film.maxFrame)")
                                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(16)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .offset(y: -24)
                    .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .photosPicker(
            isPresented: $showPhotosPicker,
            selection: $selectedPhotoItems,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedPhotoItems) {
            Task {
                await importPhotos()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    HapticService.lightImpact()
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditSessionView(session: session)
        }
    }
    
    private func importPhotos() async {
        isProcessingPhotos = true
        defer { isProcessingPhotos = false }
        
        for item in selectedPhotoItems {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    continue
                }
                
                let fileName = UUID().uuidString + ".jpg"
                let imagePath = try await StorageService.shared.saveImage(data: data, fileName: fileName)
                
                let imageURL = await StorageService.shared.getImageURL(path: imagePath)
                var photo = Photo(imagePath: imagePath)
                
                let metadata = EXIFService.shared.extractPhotoMetadata(from: imageURL)
                if let metadata = metadata {
                    photo.iso = metadata.iso
                    photo.aperture = metadata.aperture
                    photo.shutterSpeed = metadata.shutterSpeed
                    photo.focalLength = metadata.focalLength
                    photo.captureDate = metadata.captureDate
                    
                    if let gps = metadata.gpsData {
                        photo.latitude = gps.latitude
                        photo.longitude = gps.longitude
                    }
                }
                
                viewModel.addPhoto(photo)
            } catch {
                print("Error importing photo: \(error.localizedDescription)")
            }
        }
        
        selectedPhotoItems.removeAll()
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.premiumSpring, value: configuration.isPressed)
    }
}

/// Detail view for a photo
struct PhotoDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    let photo: Photo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Photo image view from storage
                ZStack {
                    if let uiImage = UIImage(contentsOfFile: StorageService.shared.getImageURL(path: photo.imagePath).path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.08), radius: 10, x: 0, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05), lineWidth: 1)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color.photoCardDark : Color.white)
                            .frame(height: 300)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.photoAccent.opacity(0.4))
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                
                // Notes section
                if !photo.note.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader("FRAME NOTES", icon: "note.text")
                        
                        GlassCardView {
                            Text(photo.note)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Metadata Section using reusable MetadataView
                MetadataView(
                    iso: photo.iso,
                    aperture: photo.aperture,
                    shutterSpeed: photo.shutterSpeed,
                    focalLength: photo.focalLength,
                    captureDate: photo.captureDate,
                    latitude: photo.latitude,
                    longitude: photo.longitude
                )
                .padding(.horizontal, 16)
                
                Spacer()
            }
        }
        .background(colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
        .navigationTitle("Frame Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
