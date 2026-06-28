import Foundation
import SwiftData

/// Represents a camera device
@Model
final class Camera: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var brand: String
    var model: String
    var purchaseYear: Int?
    var notes: String
    var createdAt: Date
    
    init(
        brand: String,
        model: String,
        purchaseYear: Int? = nil,
        notes: String = ""
    ) {
        self.brand = brand
        self.model = model
        self.purchaseYear = purchaseYear
        self.notes = notes
        self.createdAt = Date()
    }
    
    var displayName: String {
        "\(brand) \(model)"
    }
}
