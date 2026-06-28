import Foundation
import SwiftData

/// Represents a photography session
@Model
final class Session: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var date: Date
    var location: String
    var note: String
    var coverPhotoPath: String?
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var photos: [Photo] = []
    
    var camera: Camera?
    var lens: Lens?
    var filmRoll: FilmRoll?
    
    init(
        title: String,
        date: Date = Date(),
        location: String = "",
        note: String = "",
        camera: Camera? = nil,
        lens: Lens? = nil,
        filmRoll: FilmRoll? = nil
    ) {
        self.title = title
        self.date = date
        self.location = location
        self.note = note
        self.camera = camera
        self.lens = lens
        self.filmRoll = filmRoll
        self.createdAt = Date()
    }
    
    var photoCount: Int {
        photos.count
    }
    
    var hasPhotos: Bool {
        !photos.isEmpty
    }
    
    var geotaggedPhotoCount: Int {
        photos.filter { $0.hasLocation }.count
    }
}
