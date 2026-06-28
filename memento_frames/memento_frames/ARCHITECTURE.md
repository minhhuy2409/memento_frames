# 🏗️ Memento Frames - Architecture Guide

## Overview

Memento Frames is built on a clean MVVM (Model-View-ViewModel) architecture with clear separation of concerns. This document outlines the architectural patterns, design decisions, and implementation guidelines used throughout the project.

---

## Core Architecture Pattern: MVVM

### What is MVVM?

**MVVM** (Model-View-ViewModel) separates the application into three layers:

1. **Model**: Represents application data and business logic
2. **View**: Presents data to the user (SwiftUI)
3. **ViewModel**: Transforms model data for display and handles user interactions

### Why MVVM?

- ✅ **Testability**: ViewModels can be tested independently
- ✅ **Reusability**: Models can be used across different views
- ✅ **Maintainability**: Clear separation makes code easier to understand
- ✅ **Scalability**: Easy to add new features without affecting existing code

---

## Layer Breakdown

### 🗂️ Models Layer

**Location**: `Models/`

Models represent the core data structures and are persisted using SwiftData. Each model represents a distinct entity in the photography domain.

#### Session Model
```swift
@Model final class Session: Identifiable {
    // Unique identifier
    @Attribute(.unique) var id: UUID
    
    // Session metadata
    var title: String
    var date: Date
    var location: String
    var note: String
    var coverPhotoPath: String?
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade)
    var photos: [Photo]
    
    var camera: Camera?
    var lens: Lens?
    var filmRoll: FilmRoll?
}
```

**Key Points**:
- Unique `id` using UUID
- Cascade delete for photos (when session is deleted, photos are deleted too)
- Optional camera/lens/film relationships (photographer can have sessions without specific gear)

#### Photo Model
```swift
@Model final class Photo: Identifiable {
    @Attribute(.unique) var id: UUID
    
    // File reference
    var imagePath: String
    var note: String
    
    // GPS data
    var latitude: Double?
    var longitude: Double?
    
    // EXIF metadata (auto-extracted)
    var iso: Int?
    var aperture: String?
    var shutterSpeed: String?
    var focalLength: String?
    var captureDate: Date?
    
    // Tracking
    var createdAt: Date
}
```

**Key Points**:
- Stores relative path, not the actual image (images too large)
- Optional EXIF fields (some photos may not have metadata)
- GPS coordinates stored as separate latitude/longitude fields

#### Gear Models (Camera, Lens, FilmRoll)
- Independent entities that can be referenced by sessions
- Support for analog and digital workflows
- Extensible for future metadata

### 🎨 Views Layer

**Location**: `Views/`

SwiftUI views that display data to the user. Following SwiftUI best practices:

#### View Characteristics
- **State Management**: Uses `@StateObject` for ViewModels
- **Data Flow**: Unidirectional (Model → ViewModel → View)
- **Composition**: Reusable components from `Components/`
- **Navigation**: SwiftUI NavigationStack and sheet presentations

#### View Hierarchy
```
MainView (Tab Navigation)
├── LibraryView
│   ├── SessionCard (component)
│   └── SearchBar (component)
├── GearView
│   └── Camera/Lens lists
└── SettingsView
    └── Settings options

SessionDetailView
├── Session Header
├── Photos Grid
│   └── PhotoDetailView
└── PhotoMapView (conditional)
```

#### Key Views

**LibraryView**: Main browsing interface
- Search functionality (case-insensitive)
- Multiple sort options
- Delete with context menu
- Empty state when no sessions

**CreateSessionView**: Form-based creation
- Required/optional fields
- Gear selection (camera, lens, film)
- Form validation
- Error handling

**SessionDetailView**: Rich detail view
- Session metadata display
- Photo import with PhotosPicker
- EXIF metadata extraction
- Map integration for geotagged photos

**PhotoMapView**: Interactive map
- Pin annotations for each geotagged photo
- Auto-fitting region to all photos
- Empty state for non-geotagged sessions

**GearView**: Equipment management
- List cameras and lenses
- Add new equipment with full specs
- Delete gear with context menu

**SettingsView**: Configuration
- Dark mode toggle
- Film mode toggle
- App version
- Future features roadmap

### 🔧 ViewModels Layer

**Location**: `ViewModels/`

ViewModels contain the business logic and state management. They transform model data for the UI and handle user interactions.

#### ViewModel Characteristics
- **State Isolation**: `@Published` properties for reactive updates
- **Main Actor**: All use `@MainActor` for thread-safe UI updates
- **Error Handling**: Clear error messages for users
- **Loading States**: Feedback during async operations

#### SessionLibraryViewModel
```swift
@MainActor
final class SessionLibraryViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var searchText: String = ""
    @Published var selectedSort: SortOption = .newestFirst
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var filteredAndSortedSessions: [Session] // Computed
}
```

**Responsibilities**:
- Load sessions from SwiftData
- Filter sessions based on search text
- Sort sessions based on selected criteria
- Delete sessions with error handling
- Manage loading and error states

#### CreateSessionViewModel & SessionDetailViewModel
- Handle CRUD operations for sessions and photos
- Validate user input
- Load related gear (cameras, lenses, film rolls)
- Manage form state

#### CameraGearViewModel
- Load all cameras and lenses
- Add/delete gear
- Error handling for gear operations

#### SettingsViewModel
- Dark mode preference
- Film mode preference
- App version tracking
- Persistent storage via UserDefaults

### 🛠️ Services Layer

**Location**: `Services/`

Services encapsulate reusable business logic and system-level interactions.

#### EXIFService (Actor)
```swift
actor EXIFService {
    nonisolated func extractPhotoMetadata(from imageURL: URL) -> PhotoMetadata?
}
```

**Responsibilities**:
- Extract EXIF data using ImageIO framework
- Parse GPS coordinates with reference (N/S, E/W)
- Format exposure times as fractions
- Thread-safe via actor pattern

**Key Features**:
- Graceful handling of missing data
- Supports both EXIF and GPS dictionaries
- Nonisolated methods for use from main thread

#### LocationService (MainActor)
```swift
@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    func requestLocationPermission()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}
```

**Responsibilities**:
- Request location permissions
- Track current device location
- Handle location manager delegate callbacks
- Thread-safe via MainActor

#### StorageService (Actor)
```swift
actor StorageService {
    func saveImage(data: Data, fileName: String) throws -> String
    func retrieveImage(path: String) throws -> Data
    func deleteImage(path: String) throws
    nonisolated func getImageURL(path: String) -> URL
}
```

**Responsibilities**:
- Manage photo storage directories
- Save/retrieve/delete image data
- Provide file URLs for EXIF extraction
- Thread-safe file operations via actor

### 🎁 Components Layer

**Location**: `Components/`

Reusable SwiftUI components used across views.

#### SessionCard
- Displays session preview
- Shows title, location, date
- Displays photo count and gear info
- Used in LibraryView

#### MetadataBadge & SectionHeader
- Consistent UI elements
- Used in detail views
- Reusable styling

#### EmptyStateView & LoadingView
- Standardized empty/loading states
- Improves UX consistency
- Reduces code duplication

#### FormField & FormComponents
- Standardized form inputs
- Multi-line text support
- Consistent styling

### 📚 Utilities Layer

**Location**: `Utilities/`

Helper functions and mock data for testing and development.

#### MockData.swift
Provides realistic preview data generators:
- `Session.mockSessions()`: Multiple sessions with photos
- `Camera.mockCameras()`: Different camera brands
- `Lens.mockLenses()`: Various focal lengths
- `FilmRoll.mockFilmRolls()`: Different statuses

---

## Data Flow Patterns

### Create Session Flow
```
User Input (CreateSessionView)
    ↓
UpdateState (@Published in ViewModel)
    ↓
FormValidation
    ↓
CreateSession (insert into ModelContext)
    ↓
Save to SwiftData
    ↓
ErrorHandling / Success
    ↓
Dismiss Sheet & Reload Library
```

### Photo Import Flow
```
PhotosPicker Selection
    ↓
Load Image Data
    ↓
Save to Disk (StorageService)
    ↓
Extract EXIF (EXIFService)
    ↓
Create Photo Model
    ↓
Add to Session
    ↓
Save to SwiftData
```

### Search & Filter Flow
```
User Types in SearchBar
    ↓
Update @Published searchText
    ↓
View Updates (SwiftUI reactive)
    ↓
Computed Property: filteredAndSortedSessions
    ↓
Apply Search Filter
    ↓
Apply Sort
    ↓
Return Filtered Results
    ↓
View Re-renders with New Data
```

---

## Thread Safety & Concurrency

### Actor Pattern
Used for file I/O and EXIF operations to prevent race conditions:

```swift
actor StorageService {
    // Isolated methods - only one executes at a time
    func saveImage() { }
    
    // Nonisolated methods - safe to call from any context
    nonisolated func getImageURL() { }
}
```

### MainActor
Used for ViewModels and LocationService to ensure UI updates happen on main thread:

```swift
@MainActor
final class SessionLibraryViewModel: ObservableObject {
    // All code runs on main thread
}
```

### Async/Await
Used for long-running operations:

```swift
Task {
    await importPhotos() // Doesn't block UI
}
```

---

## Memory Management

### SwiftData Relationships
- `@Relationship(deleteRule: .cascade)`: Automatic cleanup
- Optional relationships: No strong cycles
- Lazy loading: Photos not loaded until needed

### Image Storage
- Photos stored as files, not in database
- Relative paths stored in Photo model
- Reduces database size significantly

### View Lifecycle
- ViewModels properly initialized with ModelContext
- No retain cycles through careful binding
- Proper cleanup on view dismissal

---

## Error Handling Strategy

### Levels of Error Handling

1. **Network/File Errors**: Try-catch blocks, user-friendly messages
2. **Validation Errors**: Form validation before submission
3. **Data Errors**: Graceful degradation (e.g., missing EXIF data)
4. **UI Errors**: Error banners, retry options

### Example Pattern
```swift
do {
    try modelContext.save()
    isLoading = false
} catch {
    errorMessage = "Failed to save: \(error.localizedDescription)"
    isLoading = false
}
```

---

## Best Practices Implemented

### ✅ MVVM Compliance
- Clear separation between views and business logic
- ViewModels contain all state and logic
- Views are purely presentational

### ✅ SwiftUI Modern Patterns
- `@StateObject` for ViewModel initialization
- Computed properties for derived state
- Efficient re-renders via @Published

### ✅ Swift 6 Features
- Actor isolation for thread safety
- Async/await for non-blocking ops
- Type-safe error handling

### ✅ Code Quality
- No force unwraps (!)
- Comprehensive error handling
- Consistent naming conventions
- Documentation comments

### ✅ Performance
- Lazy loading in grids
- Efficient filtering algorithms
- Minimal view re-renders
- Actor-based concurrency

### ✅ Testing Ready
- Dependency injection via parameters
- Mock data generators
- Isolated business logic in ViewModels
- Services are independently testable

---

## Future Extensibility

### Adding New Features

To add a new feature following this architecture:

1. **Create Model** in `Models/`
2. **Create ViewModel** in `ViewModels/`
3. **Create View** in `Views/` using components
4. **Create Service** in `Services/` if needed
5. **Add Mock Data** in `Utilities/MockData.swift`

### Example: Adding Photo Export
```swift
// 1. Create Service
actor ExportService {
    func exportSession(session: Session) throws -> URL
}

// 2. Add ViewModel method
final class SessionDetailViewModel {
    func exportSession() async throws
}

// 3. Add UI
// Button in SessionDetailView
Button(action: { Task { try await viewModel.exportSession() } })

// 4. Add to Settings view list
```

---

## Conclusion

Memento Frames demonstrates professional iOS development practices with:
- Clean architecture separation
- Thread-safe concurrency
- Comprehensive error handling
- Modern Swift/SwiftUI patterns
- Production-ready code quality

The architecture scales well for adding future features like CloudKit sync, widgets, and AI tagging without requiring major restructuring.

---

**Built with ❤️ using Swift 6, SwiftUI, and SwiftData**
