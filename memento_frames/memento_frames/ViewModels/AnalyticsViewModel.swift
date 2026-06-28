import SwiftUI
import SwiftData
import Combine

/// Data model representing monthly photo import count for Swift Charts
struct MonthlyPhotoData: Identifiable {
    let id = UUID()
    let monthName: String
    let count: Int
    let date: Date
}

/// Data model representing yearly session count for Swift Charts
struct YearlySessionData: Identifiable {
    let id = UUID()
    let year: String
    let count: Int
}

/// View model to process photography session statistics and analytics
@MainActor
class AnalyticsViewModel: ObservableObject {
    private var modelContext: ModelContext
    
    @Published var sessions: [Session] = []
    @Published var cameras: [Camera] = []
    @Published var lenses: [Lens] = []
    @Published var filmRolls: [FilmRoll] = []
    
    // Calculated statistics metrics
    @Published var totalSessionsCount = 0
    @Published var totalPhotosCount = 0
    @Published var totalCamerasCount = 0
    @Published var totalLensesCount = 0
    
    @Published var mostUsedCamera: String = "None"
    @Published var mostUsedLens: String = "None"
    @Published var mostUsedFilmRoll: String = "None"
    
    @Published var currentStreak = 0
    @Published var longestStreak = 0
    
    @Published var monthlyPhotoData: [MonthlyPhotoData] = []
    @Published var yearlySessionData: [YearlySessionData] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadDataAndCalculate()
    }
    
    func loadDataAndCalculate() {
        fetchFromDatabase()
        calculateStatistics()
    }
    
    private func fetchFromDatabase() {
        do {
            let sessionDescriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            self.sessions = try modelContext.fetch(sessionDescriptor)
            
            let cameraDescriptor = FetchDescriptor<Camera>()
            self.cameras = try modelContext.fetch(cameraDescriptor)
            
            let lensDescriptor = FetchDescriptor<Lens>()
            self.lenses = try modelContext.fetch(lensDescriptor)
            
            let filmDescriptor = FetchDescriptor<FilmRoll>()
            self.filmRolls = try modelContext.fetch(filmDescriptor)
        } catch {
            print("Failed to fetch data for analytics: \(error.localizedDescription)")
        }
    }
    
    private func calculateStatistics() {
        totalSessionsCount = sessions.count
        totalPhotosCount = sessions.reduce(0) { $0 + $1.photoCount }
        totalCamerasCount = cameras.count
        totalLensesCount = lenses.count
        
        calculateMostUsedGear()
        calculateShootingStreaks()
        generateChartData()
    }
    
    private func calculateMostUsedGear() {
        // Most used camera
        var cameraCounts: [String: Int] = [:]
        for session in sessions {
            if let camera = session.camera {
                let name = camera.displayName
                cameraCounts[name, default: 0] += 1
            }
        }
        mostUsedCamera = cameraCounts.max(by: { $0.value < $1.value })?.key ?? "None"
        
        // Most used lens
        var lensCounts: [String: Int] = [:]
        for session in sessions {
            if let lens = session.lens {
                let name = lens.displayName
                lensCounts[name, default: 0] += 1
            }
        }
        mostUsedLens = lensCounts.max(by: { $0.value < $1.value })?.key ?? "None"
        
        // Most used film
        var filmCounts: [String: Int] = [:]
        for session in sessions {
            if let film = session.filmRoll {
                let name = film.name
                filmCounts[name, default: 0] += 1
            }
        }
        mostUsedFilmRoll = filmCounts.max(by: { $0.value < $1.value })?.key ?? "None"
    }
    
    private func calculateShootingStreaks() {
        // Extract unique days of sessions
        let calendar = Calendar.current
        let sessionDates = sessions.map { calendar.startOfDay(for: $0.date) }
        let uniqueDates = Set(sessionDates).sorted(by: >) // Latest dates first
        
        guard !uniqueDates.isEmpty else {
            currentStreak = 0
            longestStreak = 0
            return
        }
        
        // Calculate current streak
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        var tempCurrentStreak = 0
        var checkDate = today
        
        // If they haven't shot today or yesterday, the current streak is 0
        if !uniqueDates.contains(today) && !uniqueDates.contains(yesterday) {
            currentStreak = 0
        } else {
            // Find start of streak check (today or yesterday)
            if uniqueDates.contains(today) {
                checkDate = today
            } else {
                checkDate = yesterday
            }
            
            while uniqueDates.contains(checkDate) {
                tempCurrentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            }
            currentStreak = tempCurrentStreak
        }
        
        // Calculate longest streak
        var tempLongest = 0
        var currentSequence = 0
        var expectedDate: Date? = nil
        
        // Go chronologically forward to count streaks
        let chronDates = uniqueDates.sorted()
        for date in chronDates {
            if let expected = expectedDate {
                if date == expected {
                    currentSequence += 1
                } else if date > expected {
                    // Gap occurred, reset
                    tempLongest = max(tempLongest, currentSequence)
                    currentSequence = 1
                }
            } else {
                currentSequence = 1
            }
            expectedDate = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        longestStreak = max(tempLongest, currentSequence)
    }
    
    private func generateChartData() {
        let calendar = Calendar.current
        let now = Date()
        
        // Generate Monthly Photo Data for the last 6 months
        var monthlyData: [MonthlyPhotoData] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        for monthOffset in (-5...0).reversed() {
            if let targetDate = calendar.date(byAdding: .month, value: monthOffset, to: now) {
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: targetDate))!
                let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
                
                // Count photos in this range
                let photoCount = sessions.filter {
                    $0.date >= monthStart && $0.date <= monthEnd
                }.reduce(0) { $0 + $1.photoCount }
                
                monthlyData.append(MonthlyPhotoData(
                    monthName: dateFormatter.string(from: targetDate),
                    count: photoCount,
                    date: targetDate
                ))
            }
        }
        self.monthlyPhotoData = monthlyData.reversed()
        
        // Generate Yearly Session Data for the past 3 years
        var yearlyData: [YearlySessionData] = []
        let currentYear = calendar.component(.year, from: now)
        
        for yearOffset in 0...2 {
            let targetYear = currentYear - yearOffset
            let sessionCount = sessions.filter {
                calendar.component(.year, from: $0.date) == targetYear
            }.count
            
            yearlyData.append(YearlySessionData(
                year: String(targetYear),
                count: sessionCount
            ))
        }
        self.yearlySessionData = yearlyData.reversed()
    }
}
