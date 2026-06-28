import SwiftUI

/// Settings screen for app configuration
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Theme background
                (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // DISPLAY SECTION
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("DISPLAY", icon: "paintbrush.fill")
                            
                            GlassCardView {
                                HStack {
                                    Label {
                                        Text("Dark Mode")
                                            .font(.system(size: 14, weight: .medium))
                                    } icon: {
                                        Image(systemName: "moon.fill")
                                            .foregroundColor(.photoAccent)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $viewModel.isDarkMode)
                                        .toggleStyle(SwitchToggleStyle(tint: .photoAccent))
                                        .labelsHidden()
                                        .onChange(of: viewModel.isDarkMode) { _ in
                                            HapticService.lightImpact()
                                        }
                                }
                                .padding(16)
                            }
                        }
                        
                        // PHOTOGRAPHY SECTION
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("PHOTOGRAPHY FEATURES", icon: "camera.shutter.button.fill")
                            
                            GlassCardView {
                                VStack(spacing: 0) {
                                    HStack {
                                        Label {
                                            Text("Film Mode")
                                                .font(.system(size: 14, weight: .medium))
                                        } icon: {
                                            Image(systemName: "film.fill")
                                                .foregroundColor(.photoAccent)
                                        }
                                        Spacer()
                                        Toggle("", isOn: $viewModel.isFilmModeEnabled)
                                            .toggleStyle(SwitchToggleStyle(tint: .photoAccent))
                                            .labelsHidden()
                                            .onChange(of: viewModel.isFilmModeEnabled) { _ in
                                                HapticService.lightImpact()
                                            }
                                    }
                                    .padding(16)
                                    
                                    Divider()
                                        .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                                        .padding(.horizontal, 16)
                                    
                                    Text("Film mode displays film rolls catalog, active frame counter trackers, and film canister badges inside gear and session details.")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .lineSpacing(4)
                                        .padding(16)
                                }
                            }
                        }
                        
                        // GEAR PORTFOLIO SECTION
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("GEAR PORTFOLIO", icon: "camera.fill")
                            
                            GlassCardView {
                                NavigationLink(destination: GearView(modelContext: modelContext)) {
                                    HStack {
                                        Label {
                                            Text("Gear Library")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.primary)
                                        } icon: {
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.photoAccent)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.photoAccent)
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .padding(16)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // ICLOUD SYNC SECTION
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("ICLOUD SYNC", icon: "icloud.fill")
                            
                            GlassCardView {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("iCloud Database")
                                                .font(.system(size: 14, weight: .medium))
                                            Text(syncManager.status.description)
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundColor(statusColor(syncManager.status))
                                        }
                                        Spacer()
                                        
                                        if syncManager.status == .syncing {
                                            ProgressView()
                                                .tint(.photoAccent)
                                        } else {
                                            Button("Sync Now") {
                                                Task {
                                                    await syncManager.performSync()
                                                }
                                            }
                                            .font(.system(size: 11, weight: .bold, design: .serif))
                                            .foregroundColor(colorScheme == .dark ? .black : .white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.photoAccent)
                                            .cornerRadius(12)
                                        }
                                    }
                                    
                                    if let lastSync = syncManager.lastSyncTime {
                                        Divider()
                                            .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                                        
                                        HStack {
                                            Text("Last Synchronized")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text(lastSync.formatted(date: .abbreviated, time: .shortened))
                                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(16)
                            }
                        }
                        
                        // DATA SECTION
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("DATA MANAGEMENT", icon: "internaldrive.fill")
                            
                            GlassCardView {
                                Button(action: {
                                    HapticService.mediumImpact()
                                    viewModel.exportData()
                                }) {
                                    HStack {
                                        Label {
                                            Text("Export Database Content")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.primary)
                                        } icon: {
                                            Image(systemName: "square.and.arrow.up")
                                                .foregroundColor(.photoAccent)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.photoAccent)
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .padding(16)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // ABOUT SECTION
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("ABOUT", icon: "info.circle.fill")
                            
                            GlassCardView {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text("App Version")
                                            .font(.system(size: 14, weight: .medium))
                                        Spacer()
                                        Text(viewModel.appVersion)
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Divider()
                                        .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("MEMENTO FRAMES")
                                            .font(.system(size: 13, weight: .bold, design: .serif))
                                            .tracking(1.5)
                                            .foregroundColor(.photoAccent)
                                        Text("A premium photo journal companion for DSLR, mirrorless, and analog street photographers to archive locations, EXIF details, and camera gear.")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .lineSpacing(4)
                                    }
                                }
                                .padding(16)
                            }
                        }
                        
                        // FUTURE SECTION
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("FUTURE DEVELOPMENTS", icon: "sparkles")
                            
                            GlassCardView {
                                VStack(alignment: .leading, spacing: 0) {
                                    futureRow(icon: "square.3.stack.3d", text: "Lock Screen Widgets")
                                    Divider().padding(.horizontal, 16)
                                    futureRow(icon: "sparkles", text: "AI Frame Tagging & Search")
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(viewModel.isDarkMode ? .dark : nil)
    }
    
    @ObservedObject private var syncManager = SyncManager.shared
    
    private func statusColor(_ status: SyncStatus) -> Color {
        switch status {
        case .idle: return .secondary
        case .syncing: return .photoAccent
        case .synced: return .green
        case .noAccount: return .orange
        case .offline: return .secondary
        case .error: return .photoRed
        }
    }
    
    @ViewBuilder
    private func futureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.secondary.opacity(0.6))
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary.opacity(0.6))
            
            Spacer()
            
            Text("SOON")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.photoAccent.opacity(0.6))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.photoAccent.opacity(0.08))
                .cornerRadius(4)
        }
        .padding(16)
    }
}

#Preview {
    SettingsView()
}
