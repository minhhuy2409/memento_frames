import Foundation

/// Service for managing file storage operations
actor StorageService {
    
    static let shared = StorageService()
    
    private let fileManager = FileManager.default
    
    /// Documents directory for storing app files
    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// Photos directory
    private var photosURL: URL {
        documentsURL.appendingPathComponent("Photos", isDirectory: true)
    }
    
    /// Initialize storage directories
    func initializeStorageDirs() throws {
        try fileManager.createDirectory(at: photosURL, withIntermediateDirectories: true)
    }
    
    /// Save image data to storage
    /// - Parameters:
    ///   - data: Image data to save
    ///   - fileName: Name for the image file
    /// - Returns: Path to the saved image
    func saveImage(data: Data, fileName: String) throws -> String {
        try initializeStorageDirs()
        
        let imageURL = photosURL.appendingPathComponent(fileName)
        try data.write(to: imageURL)
        return imageURL.relativePath
    }
    
    /// Retrieve image data from storage
    /// - Parameter path: Relative path to the image
    /// - Returns: Image data
    func retrieveImage(path: String) throws -> Data {
        let imageURL = documentsURL.appendingPathComponent(path)
        return try Data(contentsOf: imageURL)
    }
    
    /// Delete image from storage
    /// - Parameter path: Relative path to the image
    func deleteImage(path: String) throws {
        let imageURL = documentsURL.appendingPathComponent(path)
        try fileManager.removeItem(at: imageURL)
    }
    
    /// Get full URL for image path
    /// - Parameter path: Relative path to the image
    /// - Returns: Full URL to the image
    nonisolated func getImageURL(path: String) -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent(path)
    }
}
