import UIKit

/// A service to cache loaded photo thumbnails in memory to improve scrolling performance in photogrids
class ImageCacheService {
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Cache limits: max 300 images or 100MB memory footprint
        cache.countLimit = 300
        cache.totalCostLimit = 100 * 1024 * 1024
    }
    
    /// Retrieve image from memory cache
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    /// Insert image into memory cache
    func setImage(_ image: UIImage, forKey key: String) {
        // Approximate cost in bytes
        let bytesCount = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: key as NSString, cost: bytesCount)
    }
    
    /// Remove a single image from cache
    func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    /// Clear cache completely
    func clear() {
        cache.removeAllObjects()
    }
}
