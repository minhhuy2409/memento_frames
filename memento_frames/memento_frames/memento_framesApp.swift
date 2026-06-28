//
//  memento_framesApp.swift
//  memento_frames
//
//  Created by huy bin on 17/6/26.
//

import SwiftUI
import SwiftData

@main
struct memento_framesApp: App {
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(
                for: Session.self, Camera.self, Lens.self, Photo.self, FilmRoll.self,
                configurations: config
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .onAppear {
                    SyncManager.shared.setup(modelContext: modelContainer.mainContext)
                    Task {
                        await SyncManager.shared.performSync()
                    }
                }
        }
    }
}
