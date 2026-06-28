import SwiftUI

/// Component to display photo EXIF metadata with professional portfolio styling
struct MetadataView: View {
    @Environment(\.colorScheme) var colorScheme
    let iso: Int?
    let aperture: String?
    let shutterSpeed: String?
    let focalLength: String?
    let captureDate: Date?
    let latitude: Double?
    let longitude: Double?
    
    var hasMetadata: Bool {
        iso != nil || aperture != nil || shutterSpeed != nil || focalLength != nil || captureDate != nil || (latitude != nil && longitude != nil)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXIF METADATA")
                .font(.system(size: 10, weight: .bold, design: .serif))
                .tracking(2.0)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            if hasMetadata {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 14) {
                    GridRow {
                        metadataRow(icon: "slider.horizontal.3", label: "ISO", value: iso != nil ? "\(iso!)" : nil)
                        metadataRow(icon: "circle.circle", label: "Aperture", value: aperture != nil ? "f/\(aperture!)" : nil)
                    }
                    
                    Divider()
                        .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                    
                    GridRow {
                        metadataRow(icon: "timer", label: "Shutter Speed", value: shutterSpeed)
                        metadataRow(icon: "camera.macro", label: "Focal Length", value: focalLength != nil ? "\(focalLength!)mm" : nil)
                    }
                    
                    if captureDate != nil || (latitude != nil && longitude != nil) {
                        Divider()
                            .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                        
                        GridRow {
                            metadataRow(icon: "calendar", label: "Date Taken", value: captureDate?.formatted(date: .abbreviated, time: .shortened))
                            metadataRow(icon: "mappin.and.ellipse", label: "GPS Coords", value: formattedCoordinates())
                        }
                    }
                }
                .padding(16)
                .background(colorScheme == .dark ? Color.photoCardDark : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.02), radius: 8, x: 0, y: 4)
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.photoAccent)
                    
                    Text("No EXIF metadata found on this frame.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colorScheme == .dark ? Color.photoCardDark : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight, lineWidth: 1)
                )
            }
        }
    }
    
    @ViewBuilder
    private func metadataRow(icon: String, label: String, value: String?) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.photoAccent)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .serif))
                    .tracking(1.0)
                    .foregroundColor(.secondary)
                
                Text(value ?? "—")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(value != nil ? .primary : .secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func formattedCoordinates() -> String? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return String(format: "%.3f, %.3f", lat, lon)
    }
}

#Preview {
    MetadataView(
        iso: 800,
        aperture: "1.4",
        shutterSpeed: "1/500",
        focalLength: "35",
        captureDate: Date(),
        latitude: 21.0285,
        longitude: 105.8542
    )
    .padding()
    .background(Color.photoBackgroundDark)
}
