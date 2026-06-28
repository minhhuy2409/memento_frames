import Foundation
import SwiftData
import Combine

/// ViewModel for managing camera and lens gear
@MainActor
final class CameraGearViewModel: ObservableObject {
    
    @Published var cameras: [Camera] = []
    @Published var lenses: [Lens] = []
    @Published var filmRolls: [FilmRoll] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadGear()
    }
    
    /// Load all cameras and lenses
    func loadGear() {
        isLoading = true
        errorMessage = nil
        
        do {
            let cameraDescriptor = FetchDescriptor<Camera>()
            cameras = try modelContext.fetch(cameraDescriptor)
            
            let lensDescriptor = FetchDescriptor<Lens>()
            lenses = try modelContext.fetch(lensDescriptor)
            
            let filmDescriptor = FetchDescriptor<FilmRoll>()
            filmRolls = try modelContext.fetch(filmDescriptor)
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load gear: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Add a new camera
    /// - Parameters:
    ///   - brand: Camera brand
    ///   - model: Camera model
    ///   - purchaseYear: Year of purchase (optional)
    ///   - notes: Additional notes
    func addCamera(brand: String, model: String, purchaseYear: Int?, notes: String) {
        let camera = Camera(
            brand: brand,
            model: model,
            purchaseYear: purchaseYear,
            notes: notes
        )
        modelContext.insert(camera)
        
        do {
            try modelContext.save()
            loadGear()
        } catch {
            errorMessage = "Failed to add camera: \(error.localizedDescription)"
        }
    }
    
    /// Delete a camera
    /// - Parameter camera: Camera to delete
    func deleteCamera(_ camera: Camera) {
        modelContext.delete(camera)
        
        do {
            try modelContext.save()
            loadGear()
        } catch {
            errorMessage = "Failed to delete camera: \(error.localizedDescription)"
        }
    }
    
    /// Add a new lens
    /// - Parameters:
    ///   - focalLength: Focal length (e.g., "50")
    ///   - mount: Lens mount (e.g., "EF")
    ///   - aperture: Maximum aperture (e.g., "1.8")
    ///   - notes: Additional notes
    func addLens(name: String, focalLength: String, mount: String, maxAperture: String, notes: String) {
        let lens = Lens(
            name: name,
            focalLength: focalLength,
            mount: mount,
            maxAperture: maxAperture,
            notes: notes
        )
        modelContext.insert(lens)
        
        do {
            try modelContext.save()
            loadGear()
        } catch {
            errorMessage = "Failed to add lens: \(error.localizedDescription)"
        }
    }
    
    /// Delete a lens
    /// - Parameter lens: Lens to delete
    func deleteLens(_ lens: Lens) {
        modelContext.delete(lens)
        
        do {
            try modelContext.save()
            loadGear()
        } catch {
            errorMessage = "Failed to delete lens: \(error.localizedDescription)"
        }
    }
    
    /// Update a camera
    func updateCamera(_ camera: Camera, brand: String, model: String, purchaseYear: Int?, notes: String) {
        camera.brand = brand
        camera.model = model
        camera.purchaseYear = purchaseYear
        camera.notes = notes
        
        do {
            try modelContext.save()
            loadGear()
        } catch {
            errorMessage = "Failed to update camera: \(error.localizedDescription)"
        }
    }
    
    /// Update a lens
    func updateLens(_ lens: Lens, name: String, focalLength: String, mount: String, maxAperture: String, notes: String) {
        lens.name = name
        lens.focalLength = focalLength
        lens.mount = mount
        lens.maxAperture = maxAperture
        lens.notes = notes
        
        do {
            try modelContext.save()
            loadGear()
        } catch {
            errorMessage = "Failed to update lens: \(error.localizedDescription)"
        }
    }
    
    /// Add a new film roll
    func addFilmRoll(name: String, iso: Int, brand: String, currentFrame: Int, maxFrame: Int, status: FilmRollStatus, notes: String) {
        let film = FilmRoll(
            name: name,
            iso: iso,
            brand: brand,
            notes: notes,
            currentFrame: currentFrame,
            maxFrame: maxFrame,
            status: status
        )
        modelContext.insert(film)
        
        do {
            try modelContext.save()
            loadGear()
        } catch {
            errorMessage = "Failed to add film roll: \(error.localizedDescription)"
        }
    }
    
    /// Update a film roll
    func updateFilmRoll(_ filmRoll: FilmRoll, name: String, iso: Int, brand: String, currentFrame: Int, maxFrame: Int, status: FilmRollStatus, notes: String) {
        filmRoll.name = name
        filmRoll.iso = iso
        filmRoll.brand = brand
        filmRoll.currentFrame = currentFrame
        filmRoll.maxFrame = maxFrame
        filmRoll.status = status
        filmRoll.notes = notes
        
        do {
            try modelContext.save()
            loadGear()
        } catch {
            errorMessage = "Failed to update film roll: \(error.localizedDescription)"
        }
    }
    
    /// Delete a film roll
    func deleteFilmRoll(_ filmRoll: FilmRoll) {
        modelContext.delete(filmRoll)
        
        do {
            try modelContext.save()
            loadGear()
        } catch {
            errorMessage = "Failed to delete film roll: \(error.localizedDescription)"
        }
    }
}
