import SwiftUI
import SwiftData

/// Main app view with tab navigation
struct MainView: View {
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        TabView {
            // Memories tab
            LibraryView(modelContext: modelContext)
                .tabItem {
                    Label("Memories", systemImage: "photo.stack")
                }
            
            // Map tab
            GlobalMapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
            
            // Insights tab
            AnalyticsView(modelContext: modelContext)
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
            
            // Settings tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: [Session.self, Camera.self, Lens.self, Photo.self, FilmRoll.self], inMemory: true)
}
