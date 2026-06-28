import SwiftUI
import SwiftData

/// Library screen displaying all photography sessions in an editorial magazine gallery style
struct LibraryView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: SessionLibraryViewModel
    @State private var showCreateSheet = false
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: SessionLibraryViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Background Color matching theme
                (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.filteredAndSortedSessions.isEmpty {
                    VStack {
                        Spacer()
                        EmptyStateView(
                            icon: "photo.stack",
                            title: "No Sessions Yet",
                            description: "Begin cataloging your analog and DSLR journeys. Create your first photography session.",
                            action: { showCreateSheet = true },
                            actionLabel: "Create Session"
                        )
                        Spacer()
                    }
                } else {
                    VStack(spacing: 0) {
                        // Custom Search Bar & Filters Header
                        VStack(spacing: 12) {
                            SearchBar(text: $viewModel.searchText)
                                .padding(.horizontal, 16)
                            
                            // Sort & Details Bar
                            HStack {
                                Menu {
                                    ForEach(SortOption.allCases, id: \.self) { option in
                                        Button(action: {
                                            HapticService.selectionChanged()
                                            viewModel.selectedSort = option
                                        }) {
                                            HStack {
                                                Text(option.rawValue)
                                                if viewModel.selectedSort == option {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.up.arrow.down")
                                            .font(.system(size: 11))
                                        Text(viewModel.selectedSort.rawValue)
                                            .font(.system(size: 12, weight: .bold, design: .serif))
                                    }
                                    .foregroundColor(.photoAccent)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(colorScheme == .dark ? Color.photoCardDark : Color.white)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight, lineWidth: 1)
                                    )
                                }
                                
                                Spacer()
                                
                                Text("\(viewModel.filteredAndSortedSessions.count) JOURNAL\(viewModel.filteredAndSortedSessions.count == 1 ? "" : "S")")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .tracking(1.0)
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.vertical, 10)
                        
                        // Magazine Style Layout
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(viewModel.filteredAndSortedSessions) { session in
                                    NavigationLink(destination: SessionDetailView(session: session, modelContext: modelContext)) {
                                        SessionCardView(session: session)
                                    }
                                    .contextMenu {
                                        Button {
                                            HapticService.lightImpact()
                                            // Navigation to detail handles editing via sheet trigger
                                        } label: {
                                            Label("View details", systemImage: "eye")
                                        }
                                        
                                        Button(role: .destructive) {
                                            HapticService.heavyImpact()
                                            viewModel.deleteSession(session)
                                        } label: {
                                            Label("Delete Journal", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .padding(.bottom, 80) // Leave space for Floating Action Button
                        }
                    }
                }
                
                // Floating Action Button for creation
                if !viewModel.filteredAndSortedSessions.isEmpty {
                    FloatingActionButton(action: {
                        showCreateSheet = true
                    }, systemImage: "plus")
                    .padding(24)
                }
            }
            .navigationTitle("Memories")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCreateSheet) {
                NavigationStack {
                    CreateSessionView(modelContext: modelContext)
                        .onDisappear {
                            viewModel.loadSessions()
                        }
                }
            }
            .onAppear {
                viewModel.loadSessions()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.filteredAndSortedSessions.isEmpty {
                        Button(action: { showCreateSheet = true }) {
                            Image(systemName: "plus")
                                .font(.headline)
                        }
                    }
                }
            }
        }
    }
}

/// Search bar component with theme aesthetics
private struct SearchBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.photoAccent)
                .font(.system(size: 15, weight: .bold))
            
            TextField("Search memories...", text: $text)
                .font(.system(size: 14, weight: .medium))
                .textInputAutocapitalization(.none)
            
            if !text.isEmpty {
                Button(action: {
                    HapticService.lightImpact()
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(colorScheme == .dark ? Color.photoCardDark : Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.02), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Session.self, Camera.self, Lens.self, Photo.self, FilmRoll.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return LibraryView(modelContext: container.mainContext)
        .modelContainer(container)
}
