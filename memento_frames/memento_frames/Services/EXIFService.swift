import Foundation
import ImageIO
import CoreGraphics

/// Service for extracting EXIF data from images
actor EXIFService {
    
    static let shared = EXIFService()
    
    /// Extract EXIF metadata from an image
    /// - Parameter imageURL: URL to the image file
    /// - Returns: Dictionary containing extracted EXIF data
    nonisolated func extractEXIF(from imageURL: URL) -> [String: Any]? {
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) else {
            return nil
        }
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return nil
        }
        
        return properties
    }
    
    /// Extract specific EXIF data for photography
    /// - Parameter imageURL: URL to the image file
    /// - Returns: PhotoMetadata containing ISO, aperture, shutter speed, focal length, and capture date
    nonisolated func extractPhotoMetadata(from imageURL: URL) -> PhotoMetadata? {
        guard let exif = extractEXIF(from: imageURL) else {
            return nil
        }
        
        var metadata = PhotoMetadata()
        
        // Extract from EXIF dictionary
        if let exifDict = exif[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            // ISO Speed
            if let iso = exifDict[kCGImagePropertyExifISOSpeedRatings as String] {
                metadata.iso = iso as? Int
            }
            
            // Aperture (f-number)
            if let fNumber = exifDict[kCGImagePropertyExifFNumber as String] {
                if let fNum = fNumber as? CGFloat {
                    metadata.aperture = String(format: "%.1f", fNum)
                }
            }
            
            // Shutter Speed (exposure time)
            if let exposureTime = exifDict[kCGImagePropertyExifExposureTime as String] {
                if let expTime = exposureTime as? Double {
                    metadata.shutterSpeed = formatExposureTime(expTime)
                }
            }
            
            // Focal Length
            if let focalLength = exifDict[kCGImagePropertyExifFocalLength as String] {
                if let focal = focalLength as? CGFloat {
                    metadata.focalLength = String(format: "%.0f", focal)
                }
            }
            
            // Capture Date
            if let dateTimeOriginal = exifDict[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                metadata.captureDate = parseExifDate(dateTimeOriginal)
            }
            
            // Lens Model
            if let lensModel = exifDict[kCGImagePropertyExifLensModel as String] as? String {
                metadata.lensModel = lensModel
            }
        }
        
        // Extract from TIFF dictionary
        if let tiffDict = exif[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
            if let make = tiffDict[kCGImagePropertyTIFFMake as String] as? String {
                metadata.cameraMake = make
            }
            if let model = tiffDict[kCGImagePropertyTIFFModel as String] as? String {
                metadata.cameraModel = model
            }
        }
        
        // Extract GPS data
        if let gpsDict = exif[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            metadata.gpsData = parseGPSData(gpsDict)
        }
        
        return metadata
    }
    
    nonisolated private func formatExposureTime(_ exposureTime: Double) -> String {
        if exposureTime >= 1.0 {
            return String(format: "%.1f\"", exposureTime)
        } else {
            let denominator = Int(round(1.0 / exposureTime))
            return "1/\(denominator)"
        }
    }
    
    nonisolated private func parseExifDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return formatter.date(from: dateString)
    }
    
    nonisolated private func parseGPSData(_ gpsDict: [String: Any]) -> GPSData? {
        guard let latArray = gpsDict[kCGImagePropertyGPSLatitude as String] as? CGFloat,
              let lonArray = gpsDict[kCGImagePropertyGPSLongitude as String] as? CGFloat else {
            return nil
        }
        
        var latitude = Double(latArray)
        var longitude = Double(lonArray)
        
        // Apply latitude reference
        if let latRef = gpsDict[kCGImagePropertyGPSLatitudeRef as String] as? String {
            if latRef == "S" {
                latitude = -latitude
            }
        }
        
        // Apply longitude reference
        if let lonRef = gpsDict[kCGImagePropertyGPSLongitudeRef as String] as? String {
            if lonRef == "W" {
                longitude = -longitude
            }
        }
        
        let altitude = gpsDict[kCGImagePropertyGPSAltitude as String] as? Double
        
        return GPSData(latitude: latitude, longitude: longitude, altitude: altitude)
    }
}

/// Container for photo metadata
struct PhotoMetadata {
    var iso: Int?
    var aperture: String?
    var shutterSpeed: String?
    var focalLength: String?
    var captureDate: Date?
    var gpsData: GPSData?
    var cameraMake: String?
    var cameraModel: String?
    var lensModel: String?
}

/// Container for GPS data
struct GPSData {
    var latitude: Double
    var longitude: Double
    var altitude: Double?
}
