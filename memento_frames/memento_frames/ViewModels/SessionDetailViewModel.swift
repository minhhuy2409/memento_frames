import Foundation
import SwiftData
import Combine

/// ViewModel for displaying session details
@MainActor
final class SessionDetailViewModel: ObservableObject {
    
    @Published var session: Session
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedPhoto: Photo?
    
    private let modelContext: ModelContext
    
    init(session: Session, modelContext: ModelContext) {
        self.session = session
        self.modelContext = modelContext
    }
    
    /// Update session
    func updateSession() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to update session: \(error.localizedDescription)"
        }
    }
    
    /// Add photo to session
    /// - Parameter photo: Photo to add
    func addPhoto(_ photo: Photo) {
        session.photos.append(photo)
        updateSession()
    }
    
    /// Remove photo from session
    /// - Parameter photo: Photo to remove
    func removePhoto(_ photo: Photo) {
        session.photos.removeAll { $0.id == photo.id }
        updateSession()
    }
    
    /// Get geotagged photos
    var geotaggedPhotos: [Photo] {
        session.photos.filter { $0.hasLocation }
    }
    
    /// Check if session has cover photo
    var hasCoverPhoto: Bool {
        session.coverPhotoPath != nil
    }
}
