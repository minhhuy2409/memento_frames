import Foundation
import SwiftData
import Combine

/// ViewModel for creating a new session with a wizard flow
@MainActor
final class CreateSessionViewModel: ObservableObject {
    
    @Published var title: String = ""
    @Published var location: String = ""
    @Published var note: String = ""
    @Published var date: Date = Date()
    @Published var selectedCamera: Camera?
    @Published var selectedLens: Lens?
    @Published var selectedFilmRoll: FilmRoll?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var availableCameras: [Camera] = []
    @Published var availableLenses: [Lens] = []
    @Published var availableFilmRolls: [FilmRoll] = []
    
    // Wizard Steps: 1 = Details, 2 = Photos, 3 = EXIF/Gear Link
    @Published var currentStep: Int = 1
    @Published var importedPhotos: [Photo] = []
    @Published var isProcessingPhotos: Bool = false
    
    // Detected gear states for Step 3 auto-matching
    @Published var detectedNewCameraMake: String?
    @Published var detectedNewCameraModel: String?
    @Published var detectedNewLensModel: String?
    @Published var detectedNewLensFocalLength: String?
    @Published var detectedNewLensMaxAperture: String?
    @Published var detectedMatchedCamera: Camera?
    @Published var detectedMatchedLens: Lens?
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadGearOptions()
    }
    
    /// Load available cameras, lenses, and film rolls from storage
    func loadGearOptions() {
        do {
            let cameraDescriptor = FetchDescriptor<Camera>()
            availableCameras = try modelContext.fetch(cameraDescriptor)
            
            let lensDescriptor = FetchDescriptor<Lens>()
            availableLenses = try modelContext.fetch(lensDescriptor)
            
            let filmDescriptor = FetchDescriptor<FilmRoll>()
            availableFilmRolls = try modelContext.fetch(filmDescriptor)
        } catch {
            errorMessage = "Failed to load gear options: \(error.localizedDescription)"
        }
    }
    
    /// Validate form input
    /// - Returns: True if form is valid
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    /// Add photo to imported collection and inspect for auto-matching EXIF gear
    func addImportedPhoto(_ photo: Photo, metadata: PhotoMetadata?) {
        importedPhotos.append(photo)
        
        if let metadata = metadata {
            processImportedPhotoMetadata(metadata)
        }
    }
    
    /// Match camera and lens based on photo EXIF metadata
    private func processImportedPhotoMetadata(_ metadata: PhotoMetadata) {
        // Match Camera
        if let make = metadata.cameraMake, let model = metadata.cameraModel {
            let makeLower = make.lowercased()
            let modelLower = model.lowercased()
            
            if selectedCamera == nil {
                if let matchedCamera = availableCameras.first(where: {
                    $0.brand.lowercased() == makeLower && $0.model.lowercased() == modelLower
                }) {
                    self.selectedCamera = matchedCamera
                    self.detectedMatchedCamera = matchedCamera
                } else {
                    self.detectedNewCameraMake = make
                    self.detectedNewCameraModel = model
                }
            }
        }
        
        // Match Lens
        if let lensModel = metadata.lensModel {
            let lensModelLower = lensModel.lowercased()
            
            if selectedLens == nil {
                if let matchedLens = availableLenses.first(where: {
                    $0.displayName.lowercased().contains(lensModelLower) ||
                    lensModelLower.contains($0.focalLength.lowercased())
                }) {
                    self.selectedLens = matchedLens
                    self.detectedMatchedLens = matchedLens
                } else {
                    self.detectedNewLensModel = lensModel
                }
            }
        } else if let focalLength = metadata.focalLength, let aperture = metadata.aperture {
            if selectedLens == nil {
                if let matchedLens = availableLenses.first(where: {
                    $0.focalLength == focalLength && $0.maxAperture == aperture
                }) {
                    self.selectedLens = matchedLens
                    self.detectedMatchedLens = matchedLens
                } else {
                    self.detectedNewLensFocalLength = focalLength
                    self.detectedNewLensMaxAperture = aperture
                }
            }
        }
    }
    
    /// Add new Camera dynamically from suggestions
    func addNewCamera(brand: String, model: String) {
        let newCamera = Camera(brand: brand, model: model)
        modelContext.insert(newCamera)
        do {
            try modelContext.save()
            loadGearOptions()
            self.selectedCamera = newCamera
            self.detectedMatchedCamera = newCamera
            self.detectedNewCameraMake = nil
            self.detectedNewCameraModel = nil
        } catch {
            print("Failed to save suggested camera: \(error)")
        }
    }
    
    /// Add new Lens dynamically from suggestions
    func addNewLens(name: String, focalLength: String, maxAperture: String) {
        let newLens = Lens(name: name, focalLength: focalLength, mount: "Auto-Detected", maxAperture: maxAperture)
        modelContext.insert(newLens)
        do {
            try modelContext.save()
            loadGearOptions()
            self.selectedLens = newLens
            self.detectedMatchedLens = newLens
            self.detectedNewLensModel = nil
            self.detectedNewLensFocalLength = nil
            self.detectedNewLensMaxAperture = nil
        } catch {
            print("Failed to save suggested lens: \(error)")
        }
    }
    
    /// Create a new session
    /// - Returns: Created session or nil if failed
    func createSession() -> Session? {
        guard isFormValid else {
            errorMessage = "Please enter a session title"
            return nil
        }
        
        isLoading = true
        errorMessage = nil
        
        let newSession = Session(
            title: title.trimmingCharacters(in: .whitespaces),
            date: date,
            location: location.trimmingCharacters(in: .whitespaces),
            note: note.trimmingCharacters(in: .whitespaces),
            camera: selectedCamera,
            lens: selectedLens,
            filmRoll: selectedFilmRoll
        )
        
        // Link all imported photos
        newSession.photos = importedPhotos
        
        // Default cover photo is the first photo
        if let firstPhoto = importedPhotos.first {
            newSession.coverPhotoPath = firstPhoto.imagePath
        }
        
        modelContext.insert(newSession)
        
        do {
            try modelContext.save()
            isLoading = false
            return newSession
        } catch {
            errorMessage = "Failed to create session: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
    
    /// Cleanup photos from disk if creation is cancelled
    func cancelCreation() {
        for photo in importedPhotos {
            do {
                let fileURL = StorageService.shared.getImageURL(path: photo.imagePath)
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
            } catch {
                print("Failed to delete cancelled photo: \(error.localizedDescription)")
            }
        }
        importedPhotos.removeAll()
    }
}
