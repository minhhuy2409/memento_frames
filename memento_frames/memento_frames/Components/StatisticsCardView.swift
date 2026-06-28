import SwiftUI

/// A premium glassmorphic card component for displaying dashboard statistics
struct StatisticsCardView: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: String
    let icon: String
    let description: String?
    
    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.photoAccent.opacity(colorScheme == .dark ? 0.12 : 0.08))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.photoAccent)
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                    
                    Text(title.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .serif))
                        .tracking(1.2)
                        .foregroundColor(.secondary)
                }
                
                if let description = description {
                    Text(description)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    HStack {
        StatisticsCardView(title: "Sessions", value: "28", icon: "photo.stack", description: "+3 this week")
        StatisticsCardView(title: "Active Streak", value: "5 Days", icon: "flame.fill", description: "Keep shooting!")
    }
    .padding()
    .background(Color.photoBackgroundDark)
}
