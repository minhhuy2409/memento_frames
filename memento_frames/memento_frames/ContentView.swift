//
//  ContentView.swift
//  memento_frames
//
//  Created by huy bin on 17/6/26.
//

import SwiftUI
import SwiftData

/// Root content view
struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        MainView()
            .applyPhotoTheme()
            .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Session.self, Camera.self, Lens.self, Photo.self, FilmRoll.self], inMemory: true)
}
