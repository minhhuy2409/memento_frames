import SwiftUI
import MapKit

/// View displaying geotagged photos on a map
struct PhotoMapView: View {
    @Environment(\.colorScheme) var colorScheme
    let photos: [Photo]
    @State private var position: MapCameraPosition = .automatic
    
    var geotaggedPhotos: [Photo] {
        photos.filter { $0.hasLocation }
    }
    
    var body: some View {
        ZStack {
            if geotaggedPhotos.isEmpty {
                // Empty state
                (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "location.slash")
                        .font(.system(size: 44))
                        .foregroundColor(.photoAccent)
                    
                    Text("No Geotagged Frames")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(.primary)
                    
                    Text("Images in this session do not contain GPS metadata coordinates.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Map with annotations
                Map(position: $position) {
                    ForEach(geotaggedPhotos) { photo in
                        if let coordinate = photo.coordinates {
                            Annotation(
                                "",
                                coordinate: coordinate
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 22, height: 22)
                                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                                    
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.photoRed)
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard)
                .ignoresSafeArea()
                
                // Legend Overlay
                VStack {
                    HStack {
                        GlassCardView {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.photoAccent.opacity(0.12))
                                        .frame(width: 38, height: 38)
                                    
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.photoAccent)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("GEOTAG ARCHIVE")
                                        .font(.system(size: 10, weight: .bold, design: .serif))
                                        .tracking(1.0)
                                        .foregroundColor(.primary)
                                    
                                    Text("\(geotaggedPhotos.count) photo\(geotaggedPhotos.count == 1 ? "" : "s") recorded in session")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(12)
                        }
                        .padding(12)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .navigationTitle("Frame Locations")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateMapRegion()
        }
    }
    
    /// Update map region to center on all photos
    private func updateMapRegion() {
        let coordinates = geotaggedPhotos.compactMap { $0.coordinates }
        guard !coordinates.isEmpty else { return }
        
        let avgLat = coordinates.map { $0.latitude }.reduce(0, +) / Double(coordinates.count)
        let avgLon = coordinates.map { $0.longitude }.reduce(0, +) / Double(coordinates.count)
        
        let maxLat = coordinates.map { $0.latitude }.max() ?? avgLat
        let minLat = coordinates.map { $0.latitude }.min() ?? avgLat
        let maxLon = coordinates.map { $0.longitude }.max() ?? avgLon
        let minLon = coordinates.map { $0.longitude }.min() ?? avgLon
        
        var latDelta = (maxLat - minLat) * 1.3
        var lonDelta = (maxLon - minLon) * 1.3
        
        latDelta = max(latDelta, 0.05)
        lonDelta = max(lonDelta, 0.05)
        
        let center = CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
        position = .region(
            MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            )
        )
    }
}

#Preview {
    let photo1 = Photo(
        imagePath: "Photos/photo1.jpg",
        note: "Sunset",
        latitude: -33.8915,
        longitude: 151.2865,
        iso: 100,
        aperture: "2.0",
        shutterSpeed: "1/500",
        focalLength: "50"
    )
    
    NavigationStack {
        PhotoMapView(photos: [photo1])
    }
}
