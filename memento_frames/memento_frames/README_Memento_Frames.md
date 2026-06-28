# 📸 Memento Frames

![Swift 6](https://img.shields.io/badge/Swift-6-orange)
![iOS](https://img.shields.io/badge/iOS-17%2B-blue)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-green)

> *Every frame has a story.*

**Memento Frames** is a production-ready photography journal application for iOS, designed for photography enthusiasts who use film cameras, DSLRs, mirrorless cameras, and smartphones. The app enables photographers to document their photography sessions, organize their gear, preserve photo metadata, and explore their memories through an interactive map.

---

## 🎯 Key Features

### Core Features
- 📝 **Session Management**: Create and organize photography sessions with titles, dates, locations, and detailed notes
- 🎥 **Gear Management**: Track your camera bodies and lenses with specifications and purchase history
- 🖼️ **Photo Import**: Import photos directly from Photos library with automatic EXIF extraction
- 📊 **Metadata Extraction**: Automatically extract and display ISO, aperture, shutter speed, focal length, and GPS coordinates
- 🗺️ **Map View**: Visualize all geotagged photos from a session on an interactive map
- 🎞️ **Film Mode**: Optional film roll tracking for analog photographers
- 🔍 **Search & Filter**: Quick search sessions by title, location, or notes with multiple sorting options
- 🌓 **Dark Mode**: Full dark mode support for comfortable use in any lighting condition

### Photography Modes
- **Digital Photography**: Full support for digital cameras and smartphones with EXIF metadata
- **Film Photography**: Dedicated film roll tracking with status updates (shooting → finished → developed → scanned)
- **Hybrid Workflow**: Mix film and digital photos in the same session

---

## 🛠 Tech Stack

| Technology | Purpose |
|-----------|---------|
| **SwiftUI** | Modern, declarative UI framework |
| **SwiftData** | Type-safe local data persistence |
| **PhotosUI** | Photo picker with multi-image support |
| **ImageIO** | EXIF metadata extraction |
| **MapKit** | Interactive map with annotations |
| **CoreLocation** | GPS coordinate handling |
| **Actors** | Thread-safe async operations |
| **Combine** | Reactive data binding |

---

## 🧱 Architecture

Memento Frames follows the **MVVM (Model-View-ViewModel)** pattern with clear separation of concerns:

```
memento_frames/
├── Models/                    # SwiftData models
│   ├── Session.swift          # Photography session
│   ├── Photo.swift            # Individual photograph
│   ├── Camera.swift           # Camera body
│   ├── Lens.swift             # Camera lens
│   └── FilmRoll.swift         # Film information
├── Views/                     # SwiftUI views
│   ├── MainView.swift         # Tab navigation
│   ├── LibraryView.swift      # Session list
│   ├── SessionDetailView.swift # Session details
│   ├── CreateSessionView.swift # New session form
│   ├── PhotoMapView.swift     # Geotagged photos
│   ├── GearView.swift         # Camera/lens management
│   └── SettingsView.swift     # App settings
├── ViewModels/                # Business logic
│   ├── SessionLibraryViewModel.swift
│   ├── CreateSessionViewModel.swift
│   ├── SessionDetailViewModel.swift
│   ├── CameraGearViewModel.swift
│   └── SettingsViewModel.swift
├── Services/                  # Core services
│   ├── EXIFService.swift      # Photo metadata extraction
│   ├── LocationService.swift  # GPS handling
│   └── StorageService.swift   # File management
├── Components/                # Reusable UI components
│   ├── SessionCard.swift      # Session preview card
│   ├── EmptyStateView.swift   # Empty state display
│   ├── LoadingView.swift      # Loading spinner
│   └── FormComponents.swift   # Form utilities
├── Utilities/                 # Helper functions
│   └── MockData.swift         # Preview data
└── Assets/                    # Colors, fonts, icons
```

### Design Patterns

- **MVVM**: Clear separation between UI and business logic
- **Repository Pattern**: Services act as data repositories
- **Actor Pattern**: Thread-safe concurrent operations
- **Reactive Programming**: Combine for data binding
- **Dependency Injection**: ViewModels receive ModelContext

---

## 🎯 MVP Features

### 1. **Library Screen** 
- Display all photography sessions
- Search by title, location, or notes (case-insensitive)
- Sort by: newest, oldest, title (A-Z/Z-A), most photos
- Delete sessions with context menu
- Session count display

### 2. **Create Session Flow**
- Form-based session creation
- Required fields: Title
- Optional fields: Location, Date, Notes
- Camera/Lens/FilmRoll selection
- Form validation and error handling
- Loading state feedback

### 3. **Session Detail Screen**
- Session metadata display
- Gear information with badges
- Photo grid with lazy loading
- Add photos capability
- Geotagged photo count
- Map navigation for locations

### 4. **Photo Import & EXIF Extraction**
- Multi-image import from Photos library
- Automatic EXIF data extraction:
  - ISO Speed
  - Aperture (f-number)
  - Shutter Speed (formatted as fractions)
  - Focal Length
  - Date Taken
  - GPS Coordinates
- Error handling for corrupted/missing data

### 5. **Gear Management**
- Add/delete cameras with specs (brand, model, purchase year, notes)
- Add/delete lenses with specs (focal length, mount, aperture, notes)
- Display gear in session creation and details
- Context menu for quick deletion

### 6. **Map Integration**
- Display geotagged photos on interactive map
- Map markers with pin annotations
- Map region auto-fit to all photos
- Photo location details
- Empty state for sessions without locations

### 7. **Film Mode**
- Optional toggle in settings
- Track film rolls (name, ISO, brand, status)
- Film statuses: Shooting → Finished → Developed → Scanned
- Film roll association with sessions

### 8. **Settings Screen**
- Dark mode toggle
- Film mode enable/disable
- App version display
- About section
- Export data placeholder
- Future feature roadmap

---

## 📊 Data Models

### Session
```swift
@Model final class Session: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String                          // Required
    var date: Date                             // Session date
    var location: String                       // Optional location
    var note: String                           // Session notes
    var coverPhotoPath: String?                // Featured photo
    var createdAt: Date                        // Creation timestamp
    
    @Relationship(deleteRule: .cascade)
    var photos: [Photo]                        // Photos in session
    
    var camera: Camera?                        // Associated camera
    var lens: Lens?                            // Associated lens
    var filmRoll: FilmRoll?                    // Associated film
}
```

### Photo
```swift
@Model final class Photo: Identifiable {
    @Attribute(.unique) var id: UUID
    var imagePath: String                      // Local storage path
    var note: String                           // Photo notes
    var latitude: Double?                      // GPS latitude
    var longitude: Double?                     // GPS longitude
    var iso: Int?                              // ISO sensitivity
    var aperture: String?                      // f-number (e.g., "2.8")
    var shutterSpeed: String?                  // Formatted exposure (e.g., "1/500")
    var focalLength: String?                   // Focal length in mm
    var captureDate: Date?                     // When photo was taken
    var createdAt: Date                        // Import timestamp
}
```

### Camera & Gear
```swift
@Model final class Camera: Identifiable {
    @Attribute(.unique) var id: UUID
    var brand: String                          // Camera brand
    var model: String                          // Camera model
    var purchaseYear: Int?                     // Purchase year
    var notes: String                          // Additional notes
    var createdAt: Date                        // Creation timestamp
}

@Model final class Lens: Identifiable {
    @Attribute(.unique) var id: UUID
    var focalLength: String                    // Focal length (e.g., "50")
    var mount: String                          // Mount type (e.g., "EF", "RF")
    var aperture: String                       // Max aperture (e.g., "1.8")
    var notes: String                          // Additional notes
    var createdAt: Date                        // Creation timestamp
}

@Model final class FilmRoll: Identifiable {
    @Attribute(.unique) var id: UUID
    var filmName: String                       // Film name
    var isoSpeed: Int                          // Film ISO
    var brand: String                          // Film brand
    var notes: String                          // Additional notes
    var status: FilmRollStatus                 // Current status
    var createdAt: Date                        // Creation timestamp
}

enum FilmRollStatus: String, Codable {
    case shooting = "Shooting"
    case finished = "Finished"
    case developed = "Developed"
    case scanned = "Scanned"
}
```

---

## �🔧 Core Services

### EXIFService
Extracts photography metadata from images using ImageIO framework:
- ISO speed ratings
- Aperture f-number
- Shutter speed (formatted as fractions or decimals)
- Focal length
- Capture date and time
- GPS coordinates with latitude/longitude references
- **Thread-safe**: Implemented as an actor with nonisolated extraction methods

### LocationService
Manages GPS location operations:
- Requests user location permissions
- Tracks current location
- Handles location manager events
- **Main actor isolated**: All updates on main thread for UI safety

### StorageService
Handles persistent image storage:
- Creates and manages photo directories
- Saves image data to disk
- Retrieves image data
- Deletes images
- Provides full URLs for image paths
- **Actor-based**: Thread-safe file operations

---

## ✨ Key Implementation Highlights

### 1. **No Force Unwraps**
- All optional values safely unwrapped with guard statements
- Optional chaining used where appropriate
- Error handling for all throwing operations

### 2. **Async/Await**
- Modern concurrency model throughout
- Photo imports processed asynchronously
- EXIF extraction non-blocking
- UI remains responsive during operations

### 3. **Actor Pattern**
- `EXIFService`: Isolated EXIF extraction operations
- `StorageService`: Thread-safe file management
- `LocationService`: Main actor for UI updates

### 4. **Memory Management**
- No retain cycles
- Proper cleanup in ViewModels
- Cascade delete rules for related data
- Efficient photo grid lazy loading

### 5. **Search & Filter**
- Case-insensitive search
- Multiple sort options (date, title, count)
- Real-time filter updates
- Efficient string matching

### 6. **Error Handling**
- User-friendly error messages
- Graceful degradation (missing EXIF data doesn't crash)
- Loading states during operations
- Try-catch blocks in all throwing operations

---

## 📱 UI/UX Features

### Design Principles
- **Minimal Core**: Focuses on photography-specific features
- **Visual Hierarchy**: Clear distinction between sections
- **Responsive Feedback**: Loading states, error messages, success indicators
- **Accessibility**: Image alt text, color contrast, font sizes

### Navigation
- **Tab-based**: Main navigation with Library, Gear, Settings
- **Stack-based**: Drill-down navigation for details
- **Modals**: Sheet presentations for forms and pickers

### Reusable Components
- `SessionCard`: Displays session preview with metadata
- `MetadataBadge`: Shows EXIF data in compact format
- `SectionHeader`: Consistent section labeling
- `FormField`: Standardized form input
- `EmptyStateView`: Consistent empty states
- `LoadingView`: Unified loading indicator

---

## 🧪 Testing & Preview Support

Mock data generators for each model:
- `Session.mockSessions()`: Multiple sessions with photos and gear
- `Camera.mockCameras()`: Different camera brands
- `Lens.mockLenses()`: Various focal lengths and mounts
- `FilmRoll.mockFilmRolls()`: Different film statuses

All views include functional `#Preview` blocks for Xcode canvas development.

---

## 🚀 Future Enhancements (Roadmap)

### Version 2.0 (Phase 1)
- **CloudKit Sync**: Automatic iCloud synchronization across devices
- **iCloud Photos Integration**: Direct sync with iCloud Photo Library
- **Backup & Restore**: Automatic cloud backup functionality

### Version 2.1 (Phase 2)
- **Widgets**: Lock screen and home screen widgets
  - Recent sessions
  - Session statistics
  - Quick session creation
- **Spotlight Search**: Index sessions and photos for system search

### Version 2.2 (Phase 3)
- **Analytics**: Photography statistics dashboard
  - Most used camera/lens combinations
  - Photos per month statistics
  - Location heatmap
  - Film vs digital ratio
- **Export**: Export sessions as PDF or ZIP
- **Sharing**: Share sessions via Mail, Messages, etc.

### Version 3.0 (AI & Intelligence)
- **AI Image Tagging**: Automatic scene and object recognition
- **Semantic Search**: Natural language queries
  - "Show all sunset beach photos"
  - "Find photos with my Canon R5"
  - "Beach photos from summer"
- **IPTC Metadata**: Full support for IPTC fields
- **Keywords & Tags**: User-defined tagging system

### Version 3.1 (Advanced Features)
- **Face Recognition**: Auto-organize photos by people
- **Collections**: Smart collections based on criteria
- **Photo Editor**: Basic editing capabilities
- **Comparison View**: Side-by-side photo comparison
- **Frequency Analysis**: Most photographed locations

### Platform Expansion
- **macOS App**: Native Mac version via Mac Catalyst
- **Watch OS**: Session quick access from Apple Watch
- **Apple TV**: Photo slideshow and browsing

---

## 📦 Installation & Setup

### Requirements
- iOS 17 or later
- Xcode 15+
- Swift 6+

### Build & Run
```bash
# Clone repository
git clone https://github.com/yourusername/memento_frames.git
cd memento_frames

# Open in Xcode
open memento_frames.xcodeproj

# Select development team in Signing & Capabilities
# Build and run on simulator or device
```

### Configuration
1. Set the development team in Xcode project settings
2. Enable Photo Library access permissions in Info.plist
3. Enable Location services for map functionality

---

## 📋 Permissions Required

Add to `Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Memento Frames needs access to your photo library to import photos for your photography sessions.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Memento Frames uses your location to tag photos with GPS data.</string>

<key>NSCameraUsageDescription</key>
<string>Optional: Use camera for live photo capture within sessions.</string>
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- Follow Swift style guides
- No force unwraps (`!`)
- Comprehensive error handling
- Unit tests for services
- SwiftUI preview for all views

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Developer Notes

### Best Practices Followed
✅ MVVM Architecture with clear separation of concerns
✅ SwiftUI only - no UIKit
✅ SwiftData for type-safe persistence
✅ Actor protocol for thread safety
✅ Async/await for non-blocking operations
✅ Comprehensive error handling
✅ No force unwrapping
✅ Memory-efficient image handling
✅ Responsive UI with loading states
✅ Full dark mode support

### Known Limitations
- Photos stored locally only (cloud sync in v2.0)
- Offline-only operation (sync planned)
- No built-in photo editing (planned for v3.0)
- Limited EXIF support (extending in v2.2)

### Performance Considerations
- Lazy loading for photo grids
- Actor-based concurrent operations
- Efficient searchable collections
- Minimal memory footprint
- Quick app launch time

---

## 📞 Support & Contact

For questions, issues, or feature requests:
- Open an issue on GitHub
- Check existing documentation
- Review the README and code comments

---

**Memento Frames — Every frame has a story.** 📸

Built with ❤️ using Swift and SwiftUI
