import Foundation
import SwiftData
import Combine

/// ViewModel for the Library screen showing all sessions
@MainActor
final class SessionLibraryViewModel: ObservableObject {
    
    @Published var sessions: [Session] = []
    @Published var searchText: String = ""
    @Published var selectedSort: SortOption = .newestFirst
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSessions()
    }
    
    var filteredAndSortedSessions: [Session] {
        var filtered = sessions
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { session in
                session.title.localizedCaseInsensitiveContains(searchText) ||
                session.location.localizedCaseInsensitiveContains(searchText) ||
                session.note.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply sorting
        switch selectedSort {
        case .newestFirst:
            filtered.sort { $0.date > $1.date }
        case .oldestFirst:
            filtered.sort { $0.date < $1.date }
        case .titleAZ:
            filtered.sort { $0.title < $1.title }
        case .titleZA:
            filtered.sort { $0.title > $1.title }
        case .mostPhotos:
            filtered.sort { $0.photoCount > $1.photoCount }
        }
        
        return filtered
    }
    
    /// Load all sessions from storage
    func loadSessions() {
        isLoading = true
        errorMessage = nil
        
        do {
            let descriptor = FetchDescriptor<Session>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            sessions = try modelContext.fetch(descriptor)
            isLoading = false
        } catch {
            errorMessage = "Failed to load sessions: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Delete a session
    /// - Parameter session: Session to delete
    func deleteSession(_ session: Session) {
        modelContext.delete(session)
        
        do {
            try modelContext.save()
            loadSessions()
        } catch {
            errorMessage = "Failed to delete session: \(error.localizedDescription)"
        }
    }
    
    /// Delete multiple sessions
    /// - Parameter sessions: Sessions to delete
    func deleteSessions(_ sessions: [Session]) {
        for session in sessions {
            modelContext.delete(session)
        }
        
        do {
            try modelContext.save()
            loadSessions()
        } catch {
            errorMessage = "Failed to delete sessions: \(error.localizedDescription)"
        }
    }
}

enum SortOption: String, CaseIterable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
    case titleAZ = "Title (A-Z)"
    case titleZA = "Title (Z-A)"
    case mostPhotos = "Most Photos"
}
