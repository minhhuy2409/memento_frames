import Foundation
import SwiftData

/// Represents a camera lens
@Model
final class Lens: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var focalLength: String
    var mount: String
    var maxAperture: String
    var notes: String
    var createdAt: Date
    
    init(
        name: String = "",
        focalLength: String,
        mount: String,
        maxAperture: String = "",
        notes: String = ""
    ) {
        self.name = name
        self.focalLength = focalLength
        self.mount = mount
        self.maxAperture = maxAperture
        self.notes = notes
        self.createdAt = Date()
    }
    
    var displayName: String {
        if name.isEmpty {
            return "\(focalLength)mm f/\(maxAperture)"
        } else {
            return "\(name) (\(focalLength)mm f/\(maxAperture))"
        }
    }
}
