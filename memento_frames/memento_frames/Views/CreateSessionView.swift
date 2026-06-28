import SwiftUI
import SwiftData
import PhotosUI

/// View for creating a new photography session with a step-by-step wizard flow
struct CreateSessionView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: CreateSessionViewModel
    
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    
    @MainActor
    init(modelContext: ModelContext? = nil) {
        let context = modelContext ?? .preview
        _viewModel = StateObject(wrappedValue: CreateSessionViewModel(modelContext: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Theme background
                (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Wizard Step Progress Indicator
                    stepIndicator
                        .padding(.top, 10)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            if viewModel.currentStep == 1 {
                                step1Details
                                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                            } else if viewModel.currentStep == 2 {
                                step2Photos
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            } else if viewModel.currentStep == 3 {
                                step3GearLink
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            }
                            
                            // Navigation action buttons
                            navigationButtons
                                .padding(.top, 10)
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("New Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        HapticService.lightImpact()
                        viewModel.cancelCreation()
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Step Indicator
    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(1...3, id: \.self) { step in
                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.currentStep >= step ? Color.photoAccent : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Text(stepName(for: step))
                        .font(.system(size: 10, weight: .bold, design: .serif))
                        .tracking(1.0)
                        .foregroundColor(viewModel.currentStep == step ? .primary : .secondary)
                }
                
                if step < 3 {
                    Spacer()
                        .frame(height: 1)
                        .background(viewModel.currentStep > step ? Color.photoAccent : Color.secondary.opacity(0.2))
                        .padding(.horizontal, 12)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
    
    private func stepName(for step: Int) -> String {
        switch step {
        case 1: return "Story"
        case 2: return "Photos"
        case 3: return "Link Gear"
        default: return ""
        }
    }
    
    // MARK: - Step 1: Details
    private var step1Details: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader("JOURNAL DETAILS", icon: "pencil.line")
                
                GlassCardView {
                    VStack(spacing: 16) {
                        FormField(label: "Title (Required)", text: $viewModel.title, placeholder: "e.g. Golden Hour Walks")
                        FormField(label: "Location", text: $viewModel.location, placeholder: "e.g. Hanoi, Vietnam")
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("DATE")
                                .font(.system(size: 11, weight: .bold, design: .serif))
                                .tracking(1.2)
                                .foregroundColor(.secondary)
                            
                            DatePicker("Select Date", selection: $viewModel.date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .tint(.photoAccent)
                        }
                    }
                    .padding(16)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader("SESSION NOTES", icon: "note.text")
                
                GlassCardView {
                    FormField(
                        label: "Notes",
                        text: $viewModel.note,
                        placeholder: "Record weather, settings, lens thoughts, film emulsions, etc.",
                        isMultiline: true
                    )
                    .padding(16)
                }
            }
        }
    }
    
    // MARK: - Step 2: Photos
    private var step2Photos: some View {
        VStack(spacing: 20) {
            PhotosPicker(
                selection: $selectedPhotoItems,
                matching: .images,
                photoLibrary: .shared()
            ) {
                GlassCardView {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 36))
                            .foregroundColor(.photoAccent)
                        Text("Import Photos")
                            .font(.system(size: 15, weight: .bold, design: .serif))
                        Text("We will automatically detect capture parameters (aperture, focal range, location).")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .padding(.horizontal, 16)
                }
            }
            .onChange(of: selectedPhotoItems) {
                Task {
                    await importPhotos()
                }
            }
            
            if viewModel.isProcessingPhotos {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.photoAccent)
                    Text("Extracting metadata...")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            if !viewModel.importedPhotos.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader("Imported Photos (\(viewModel.importedPhotos.count))", icon: "photo.stack")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.importedPhotos) { photo in
                                ZStack(alignment: .topTrailing) {
                                    PhotoThumbnailView(photo: photo, height: 90)
                                        .frame(width: 90)
                                        .cornerRadius(12)
                                    
                                    Button(action: {
                                        if let index = viewModel.importedPhotos.firstIndex(where: { $0.id == photo.id }) {
                                            viewModel.importedPhotos.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(4)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Step 3: Gear Link
    private var step3GearLink: some View {
        VStack(spacing: 20) {
            // 1. Matched Camera Success Box
            if let matchedCamera = viewModel.detectedMatchedCamera {
                GlassCardView {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AUTO-MATCHED CAMERA")
                                .font(.system(size: 10, weight: .bold, design: .serif))
                                .foregroundColor(.secondary)
                            Text(matchedCamera.displayName)
                                .font(.system(size: 14, weight: .bold))
                        }
                        Spacer()
                    }
                    .padding(14)
                }
            } else if let make = viewModel.detectedNewCameraMake, let model = viewModel.detectedNewCameraModel {
                // Suggest adding camera to library
                GlassCardView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "camera.badge.ellipsis")
                                .foregroundColor(.photoAccent)
                                .font(.title3)
                            Text("New Camera Detected")
                                .font(.system(size: 13, weight: .bold, design: .serif))
                            Spacer()
                        }
                        
                        Text("We detected this session was shot with a **\(make) \(model)**. Would you like to add it to your gear library?")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                HapticService.success()
                                viewModel.addNewCamera(brand: make, model: model)
                            }) {
                                Text("Add & Link Camera")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.photoAccent)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                HapticService.lightImpact()
                                viewModel.detectedNewCameraMake = nil
                                viewModel.detectedNewCameraModel = nil
                            }) {
                                Text("Skip")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.secondary.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(14)
                }
            }
            
            // 2. Matched Lens Success Box
            if let matchedLens = viewModel.detectedMatchedLens {
                GlassCardView {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AUTO-MATCHED LENS")
                                .font(.system(size: 10, weight: .bold, design: .serif))
                                .foregroundColor(.secondary)
                            Text(matchedLens.displayName)
                                .font(.system(size: 14, weight: .bold))
                        }
                        Spacer()
                    }
                    .padding(14)
                }
            } else if let lensModel = viewModel.detectedNewLensModel {
                GlassCardView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lens")
                                .foregroundColor(.photoAccent)
                                .font(.title3)
                            Text("New Lens Detected")
                                .font(.system(size: 13, weight: .bold, design: .serif))
                            Spacer()
                        }
                        
                        Text("We detected a lens identified as **\(lensModel)**. Add it to your gear library?")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                HapticService.success()
                                viewModel.addNewLens(name: lensModel, focalLength: "Auto", maxAperture: "Auto")
                            }) {
                                Text("Add & Link Lens")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.photoAccent)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                HapticService.lightImpact()
                                viewModel.detectedNewLensModel = nil
                            }) {
                                Text("Skip")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.secondary.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(14)
                }
            } else if let focalLength = viewModel.detectedNewLensFocalLength, let aperture = viewModel.detectedNewLensMaxAperture {
                GlassCardView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lens")
                                .foregroundColor(.photoAccent)
                                .font(.title3)
                            Text("New Lens Detected")
                                .font(.system(size: 13, weight: .bold, design: .serif))
                            Spacer()
                        }
                        
                        Text("We detected a lens matching parameters **\(focalLength)mm f/\(aperture)**. Add it to your gear library?")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                HapticService.success()
                                viewModel.addNewLens(name: "", focalLength: focalLength, maxAperture: aperture)
                            }) {
                                Text("Add & Link Lens")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.photoAccent)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                HapticService.lightImpact()
                                viewModel.detectedNewLensFocalLength = nil
                                viewModel.detectedNewLensMaxAperture = nil
                            }) {
                                Text("Skip")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.secondary.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(14)
                }
            }
            
            // 3. Manual Assignment overrides
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader("MANUAL GEAR ASSIGNMENT", icon: "gearshape")
                
                GlassCardView {
                    VStack(spacing: 14) {
                        // Camera Selector
                        Picker("Camera", selection: $viewModel.selectedCamera) {
                            Text("None assigned").tag(nil as Camera?)
                            ForEach(viewModel.availableCameras, id: \.id) { camera in
                                Text(camera.displayName).tag(camera as Camera?)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Divider()
                            .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                        
                        // Lens Selector
                        Picker("Lens", selection: $viewModel.selectedLens) {
                            Text("None assigned").tag(nil as Lens?)
                            ForEach(viewModel.availableLenses, id: \.id) { lens in
                                Text(lens.displayName).tag(lens as Lens?)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        // Film Roll Selection (if Film Mode is enabled)
                        if UserDefaults.standard.bool(forKey: "isFilmModeEnabled") {
                            Divider()
                                .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                            
                            Picker("Film Roll", selection: $viewModel.selectedFilmRoll) {
                                Text("None assigned").tag(nil as FilmRoll?)
                                ForEach(viewModel.availableFilmRolls, id: \.id) { filmRoll in
                                    Text(filmRoll.name).tag(filmRoll as FilmRoll?)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
    
    // MARK: - Navigation Control Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if viewModel.currentStep > 1 {
                Button(action: {
                    HapticService.lightImpact()
                    withAnimation(.premiumSpring) {
                        viewModel.currentStep -= 1
                    }
                }) {
                    Text("BACK")
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .tracking(1.5)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.secondary.opacity(0.15))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            Button(action: {
                HapticService.lightImpact()
                if viewModel.currentStep < 3 {
                    withAnimation(.premiumSpring) {
                        viewModel.currentStep += 1
                    }
                } else {
                    createSession()
                }
            }) {
                Text(viewModel.currentStep == 3 ? "SAVE JOURNAL" : "CONTINUE")
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .tracking(1.5)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isFormValid ? Color.photoAccent : Color.photoAccent.opacity(0.35))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .cornerRadius(16)
                    .shadow(color: Color.photoAccent.opacity(viewModel.isFormValid ? 0.25 : 0), radius: 6, x: 0, y: 3)
            }
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    // MARK: - Photo Import Worker
    private func importPhotos() async {
        viewModel.isProcessingPhotos = true
        defer { viewModel.isProcessingPhotos = false }
        
        for item in selectedPhotoItems {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    continue
                }
                
                let fileName = UUID().uuidString + ".jpg"
                let imagePath = try await StorageService.shared.saveImage(data: data, fileName: fileName)
                
                let imageURL = await StorageService.shared.getImageURL(path: imagePath)
                let photo = Photo(imagePath: imagePath)
                
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
                
                viewModel.addImportedPhoto(photo, metadata: metadata)
            } catch {
                print("Error importing photo in wizard: \(error.localizedDescription)")
            }
        }
        
        selectedPhotoItems.removeAll()
    }
    
    private func createSession() {
        HapticService.success()
        if let _ = viewModel.createSession() {
            dismiss()
        }
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.premiumSpring, value: configuration.isPressed)
    }
}

#Preview {
    CreateSessionView()
        .modelContainer(for: [Session.self, Camera.self, Lens.self, Photo.self, FilmRoll.self], inMemory: true)
}
