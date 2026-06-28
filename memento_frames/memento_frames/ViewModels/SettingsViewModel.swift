import Foundation
import Combine

/// ViewModel for settings
@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var isDarkMode: Bool = false {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var isFilmModeEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isFilmModeEnabled, forKey: "isFilmModeEnabled")
        }
    }
    
    @Published var appVersion: String = ""
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.isFilmModeEnabled = UserDefaults.standard.bool(forKey: "isFilmModeEnabled")
        setupAppVersion()
    }
    
    private func setupAppVersion() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        } else {
            appVersion = "1.0.0"
        }
    }
    
    /// Export all data (placeholder for future implementation)
    func exportData() {
        // Placeholder for future CloudKit/file export implementation
    }
}
