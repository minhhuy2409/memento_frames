import Foundation
import SwiftData

/// Represents film roll information for analog photography
@Model
final class FilmRoll: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var iso: Int
    var brand: String
    var notes: String
    var currentFrame: Int
    var maxFrame: Int
    var status: FilmRollStatus
    var createdAt: Date
    
    init(
        name: String,
        iso: Int = 400,
        brand: String = "",
        notes: String = "",
        currentFrame: Int = 0,
        maxFrame: Int = 36,
        status: FilmRollStatus = .shooting
    ) {
        self.name = name
        self.iso = iso
        self.brand = brand
        self.notes = notes
        self.currentFrame = currentFrame
        self.maxFrame = maxFrame
        self.status = status
        self.createdAt = Date()
    }
    
    var displayName: String {
        "\(brand) \(name) (ISO \(iso))"
    }
}

enum FilmRollStatus: String, Codable, CaseIterable {
    case shooting = "Shooting"
    case finished = "Finished"
    case developed = "Developed"
    case scanned = "Scanned"
}
