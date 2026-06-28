import SwiftUI
import SwiftData

/// Insights and Analytics Dashboard view for Memento Frames
struct AnalyticsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: AnalyticsViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: AnalyticsViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Theme background
                (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // GRID OF COUNTERS
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            StatisticsCardView(
                                title: "Journals",
                                value: "\(viewModel.totalSessionsCount)",
                                icon: "photo.stack",
                                description: "Sessions recorded"
                            )
                            
                            StatisticsCardView(
                                title: "Frames",
                                value: "\(viewModel.totalPhotosCount)",
                                icon: "photo",
                                description: "Total images"
                            )
                            
                            StatisticsCardView(
                                title: "Active Streak",
                                value: "\(viewModel.currentStreak) Days",
                                icon: "flame.fill",
                                description: "Consecutive shoots"
                            )
                            
                            StatisticsCardView(
                                title: "Longest Streak",
                                value: "\(viewModel.longestStreak) Days",
                                icon: "crown.fill",
                                description: "Max shoot streak"
                            )
                        }
                        
                        // Swift Charts Display Card
                        ChartsView(
                            monthlyData: viewModel.monthlyPhotoData,
                            yearlyData: viewModel.yearlySessionData
                        )
                        
                        // GEAR FAVORITES
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("GEAR FAVORITES", icon: "camera.fill")
                            
                            GlassCardView {
                                VStack(alignment: .leading, spacing: 14) {
                                    gearFavoriteRow(icon: "camera.fill", label: "Favorite Camera", value: viewModel.mostUsedCamera)
                                    
                                    Divider()
                                        .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                                    
                                    gearFavoriteRow(icon: "camera.macro", label: "Favorite Lens", value: viewModel.mostUsedLens)
                                    
                                    if UserDefaults.standard.bool(forKey: "isFilmModeEnabled") {
                                        Divider()
                                            .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                                        
                                        gearFavoriteRow(icon: "film.fill", label: "Favorite Film stock", value: viewModel.mostUsedFilmRoll)
                                    }
                                }
                                .padding(16)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadDataAndCalculate()
            }
        }
    }
    
    @ViewBuilder
    private func gearFavoriteRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.photoAccent.opacity(colorScheme == .dark ? 0.12 : 0.08))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .foregroundColor(.photoAccent)
                    .font(.system(size: 14, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .serif))
                    .tracking(1.2)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Session.self, Camera.self, Lens.self, Photo.self, FilmRoll.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return AnalyticsView(modelContext: container.mainContext)
        .modelContainer(container)
}
