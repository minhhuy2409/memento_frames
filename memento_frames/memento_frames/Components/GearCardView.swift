import SwiftUI
import SwiftData

/// Card component to display camera, lens, or film roll details
struct GearCardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    enum GearItem {
        case camera(Camera)
        case lens(Lens)
        case filmRoll(FilmRoll)
    }
    
    let item: GearItem
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch item {
            case .camera(let camera):
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.photoAccent.opacity(colorScheme == .dark ? 0.12 : 0.08))
                            .frame(width: 46, height: 46)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.photoAccent)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(camera.brand.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .serif))
                            .tracking(1.2)
                            .foregroundColor(.secondary)
                        
                        Text(camera.model)
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    if let year = camera.purchaseYear {
                        Text("\(String(year))")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                            .cornerRadius(6)
                    }
                }
                
                if !camera.notes.isEmpty {
                    Text(camera.notes)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
                
            case .lens(let lens):
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.photoAccent.opacity(colorScheme == .dark ? 0.12 : 0.08))
                            .frame(width: 46, height: 46)
                        
                        Image(systemName: "camera.macro")
                            .font(.system(size: 18))
                            .foregroundColor(.photoAccent)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        if !lens.name.isEmpty {
                            Text(lens.name)
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(.primary)
                        } else {
                            Text("\(lens.focalLength)mm")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(.primary)
                        }
                        
                        Text("\(lens.mount.uppercased()) MOUNT")
                            .font(.system(size: 10, weight: .bold, design: .serif))
                            .tracking(1.2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("f/\(lens.maxAperture)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.photoAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                        .cornerRadius(6)
                }
                
                if !lens.notes.isEmpty {
                    Text(lens.notes)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
                
            case .filmRoll(let filmRoll):
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.photoAccent.opacity(colorScheme == .dark ? 0.12 : 0.08))
                                .frame(width: 46, height: 46)
                            
                            Image(systemName: "film.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.photoAccent)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(filmRoll.brand.uppercased())
                                .font(.system(size: 10, weight: .bold, design: .serif))
                                .tracking(1.2)
                                .foregroundColor(.secondary)
                            
                            Text(filmRoll.name)
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Text("ISO \(filmRoll.iso)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.photoAccent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                            .cornerRadius(6)
                    }
                    
                    // Frame counter bar
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("FRAMES: \(filmRoll.currentFrame) / \(filmRoll.maxFrame)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(filmRoll.status.rawValue.uppercased())
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(statusColor(filmRoll.status))
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geometry.size.width, height: 5)
                                    .opacity(colorScheme == .dark ? 0.08 : 0.06)
                                    .foregroundColor(.secondary)
                                
                                Rectangle()
                                    .frame(width: min(CGFloat(filmRoll.currentFrame) / CGFloat(filmRoll.maxFrame) * geometry.size.width, geometry.size.width), height: 5)
                                    .foregroundColor(.photoAccent)
                            }
                            .cornerRadius(3)
                        }
                        .frame(height: 5)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(16)
        .background(colorScheme == .dark ? Color.photoCardDark : Color.photoCardLight)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    colorScheme == .dark 
                        ? Color.white.opacity(0.08) 
                        : Color.black.opacity(0.05), 
                    lineWidth: 1
                )
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.03),
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    private func statusColor(_ status: FilmRollStatus) -> Color {
        switch status {
        case .shooting: return .photoAccent
        case .finished: return .orange
        case .developed: return .purple
        case .scanned: return .green
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        GearCardView(item: .camera(Camera(brand: "Fujifilm", model: "X-T5", purchaseYear: 2023, notes: "Daily camera")))
        GearCardView(item: .lens(Lens(name: "35mm Prime", focalLength: "35", mount: "X", maxAperture: "1.4")))
        GearCardView(item: .filmRoll(FilmRoll(name: "Superia 400", iso: 400, brand: "Fujifilm", currentFrame: 18, maxFrame: 36, status: .shooting)))
    }
    .padding()
    .background(Color.photoBackgroundDark)
}
