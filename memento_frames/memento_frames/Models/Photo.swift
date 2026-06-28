import Foundation
import SwiftData
import MapKit

/// Represents a photograph with metadata
@Model
final class Photo: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var imagePath: String
    var note: String
    var latitude: Double?
    var longitude: Double?
    var iso: Int?
    var aperture: String?
    var shutterSpeed: String?
    var focalLength: String?
    var captureDate: Date?
    var createdAt: Date
    
    init(
        imagePath: String,
        note: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        iso: Int? = nil,
        aperture: String? = nil,
        shutterSpeed: String? = nil,
        focalLength: String? = nil,
        captureDate: Date? = nil
    ) {
        self.imagePath = imagePath
        self.note = note
        self.latitude = latitude
        self.longitude = longitude
        self.iso = iso
        self.aperture = aperture
        self.shutterSpeed = shutterSpeed
        self.focalLength = focalLength
        self.captureDate = captureDate
        self.createdAt = Date()
    }
    
    var coordinates: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var hasLocation: Bool {
        latitude != nil && longitude != nil
    }
}
