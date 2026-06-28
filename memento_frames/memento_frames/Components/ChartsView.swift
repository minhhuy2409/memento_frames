import SwiftUI
import Charts

/// A component utilizing Swift Charts to display monthly photo distribution and yearly session history
struct ChartsView: View {
    @Environment(\.colorScheme) var colorScheme
    let monthlyData: [MonthlyPhotoData]
    let yearlyData: [YearlySessionData]
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tab switch control
            Picker("Chart Type", selection: $selectedTab) {
                Text("Photos / Month").tag(0)
                Text("Sessions / Year").tag(1)
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedTab) { _ in
                HapticService.lightImpact()
            }
            
            if selectedTab == 0 {
                // Monthly Photo Bar Chart
                VStack(alignment: .leading, spacing: 10) {
                    Text("MONTHLY FRAMES RECORDED")
                        .font(.system(size: 9, weight: .bold, design: .serif))
                        .tracking(1.5)
                        .foregroundColor(.secondary)
                    
                    if monthlyData.isEmpty || monthlyData.allSatisfy({ $0.count == 0 }) {
                        emptyChartPlaceholder(message: "No frames recorded in the last 6 months.")
                    } else {
                        Chart {
                            ForEach(monthlyData) { data in
                                BarMark(
                                    x: .value("Month", data.monthName),
                                    y: .value("Count", data.count)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.photoAccent, .photoAccent.opacity(0.4)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(6)
                            }
                        }
                        .frame(height: 180)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    }
                }
            } else {
                // Yearly Session Bar Chart
                VStack(alignment: .leading, spacing: 10) {
                    Text("ANNUAL JOURNAL SESSIONS")
                        .font(.system(size: 9, weight: .bold, design: .serif))
                        .tracking(1.5)
                        .foregroundColor(.secondary)
                    
                    if yearlyData.isEmpty || yearlyData.allSatisfy({ $0.count == 0 }) {
                        emptyChartPlaceholder(message: "No sessions recorded yet.")
                    } else {
                        Chart {
                            ForEach(yearlyData) { data in
                                BarMark(
                                    x: .value("Year", data.year),
                                    y: .value("Count", data.count)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.photoAccent, .photoAccent.opacity(0.4)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(6)
                            }
                        }
                        .frame(height: 180)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    }
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
    }
    
    @ViewBuilder
    private func emptyChartPlaceholder(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 28))
                .foregroundColor(.photoAccent.opacity(0.4))
            
            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight, lineWidth: 1)
        )
    }
}
