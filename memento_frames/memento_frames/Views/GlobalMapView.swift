import SwiftUI
import MapKit
import SwiftData

/// Global map view displaying photo geotags from all sessions
struct GlobalMapView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedItem: MapAnnotationItem? = nil
    @State private var showSessionDetail = false
    
    struct MapAnnotationItem: Identifiable, Hashable {
        let id: UUID
        let coordinate: CLLocationCoordinate2D
        let session: Session
        let photo: Photo
        
        static func == (lhs: MapAnnotationItem, rhs: MapAnnotationItem) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    var annotationItems: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []
        for session in sessions {
            for photo in session.photos {
                if let coord = photo.coordinates {
                    items.append(MapAnnotationItem(
                        id: photo.id,
                        coordinate: coord,
                        session: session,
                        photo: photo
                    ))
                }
            }
        }
        return items
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if annotationItems.isEmpty {
                    // Empty State
                    (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                        .ignoresSafeArea()
                    
                    EmptyStateView(
                        icon: "map.fill",
                        title: "No Photo Locations Yet",
                        description: "Photos with GPS metadata will automatically map to this viewport. Tap mapping on details to view.",
                        action: nil,
                        actionLabel: ""
                    )
                } else {
                    // Map View
                    Map(position: $position) {
                        ForEach(annotationItems) { item in
                            Annotation(
                                item.session.title,
                                coordinate: item.coordinate
                            ) {
                                Button(action: {
                                    HapticService.lightImpact()
                                    withAnimation(.premiumSpring) {
                                        selectedItem = item
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 24, height: 24)
                                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
                                        
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.system(size: 26))
                                            .foregroundColor(.photoRed)
                                    }
                                }
                            }
                        }
                    }
                    .mapStyle(.standard)
                    .ignoresSafeArea(edges: .top)
                    
                    // Selected Item Glass Overlay Card
                    if let item = selectedItem {
                        VStack {
                            Spacer()
                            
                            GlassCardView {
                                HStack(spacing: 12) {
                                    // Photo Thumbnail
                                    if let uiImage = UIImage(contentsOfFile: StorageService.shared.getImageURL(path: item.photo.imagePath).path) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 65, height: 65)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                                            .frame(width: 65, height: 65)
                                            .overlay(Image(systemName: "photo").foregroundColor(.secondary))
                                    }
                                    
                                    // Text details
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.session.title)
                                            .font(.system(size: 16, weight: .bold, design: .serif))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        if !item.session.location.isEmpty {
                                            HStack(spacing: 3) {
                                                Image(systemName: "mappin.circle.fill")
                                                    .font(.caption2)
                                                    .foregroundColor(.photoAccent)
                                                Text(item.session.location)
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundColor(.secondary)
                                            }
                                            .lineLimit(1)
                                        }
                                        
                                        Text(item.session.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Action Button
                                    Button(action: {
                                        HapticService.mediumImpact()
                                        showSessionDetail = true
                                    }) {
                                        Image(systemName: "chevron.right.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.photoAccent)
                                    }
                                    .buttonStyle(ScaleEffectButtonStyle())
                                }
                                .padding(14)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
            .navigationTitle("Memory Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSessionDetail) {
                if let item = selectedItem {
                    NavigationStack {
                        SessionDetailView(session: item.session, modelContext: modelContext)
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button("Close") {
                                        HapticService.lightImpact()
                                        showSessionDetail = false
                                    }
                                }
                            }
                    }
                }
            }
            .onAppear {
                updateMapRegion()
            }
        }
    }
    
    private func updateMapRegion() {
        let items = annotationItems
        guard !items.isEmpty else { return }
        
        let coordinates = items.map { $0.coordinate }
        let avgLat = coordinates.map { $0.latitude }.reduce(0, +) / Double(coordinates.count)
        let avgLon = coordinates.map { $0.longitude }.reduce(0, +) / Double(coordinates.count)
        
        let maxLat = coordinates.map { $0.latitude }.max() ?? avgLat
        let minLat = coordinates.map { $0.latitude }.min() ?? avgLat
        let maxLon = coordinates.map { $0.longitude }.max() ?? avgLon
        let minLon = coordinates.map { $0.longitude }.min() ?? avgLon
        
        var latDelta = (maxLat - minLat) * 1.4
        var lonDelta = (maxLon - minLon) * 1.4
        
        latDelta = max(latDelta, 0.08)
        lonDelta = max(lonDelta, 0.08)
        
        position = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon),
                span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            )
        )
    }
}

private struct ScaleEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .animation(.premiumSpring, value: configuration.isPressed)
    }
}

#Preview {
    GlobalMapView()
        .modelContainer(for: [Session.self, Camera.self, Lens.self, Photo.self, FilmRoll.self], inMemory: true)
}
