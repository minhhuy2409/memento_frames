import Foundation
import SwiftData

extension ModelContext {
    @MainActor
    static let preview: ModelContext = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: Session.self, Camera.self, Lens.self, Photo.self, FilmRoll.self,
                configurations: config
            )
            return container.mainContext
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error.localizedDescription)")
        }
    }()
}
