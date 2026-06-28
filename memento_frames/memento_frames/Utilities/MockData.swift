import Foundation

/// Extension for generating mock data for testing and previews
extension Session {
    static func mockSessions() -> [Session] {
        let camera1 = Camera(brand: "Canon", model: "R5", purchaseYear: 2021, notes: "Main camera")
        let camera2 = Camera(brand: "Fujifilm", model: "XT-5", purchaseYear: 2023)
        
        let lens1 = Lens(name: "RF 50mm", focalLength: "50", mount: "RF", maxAperture: "1.8")
        let lens2 = Lens(name: "RF 24-70mm", focalLength: "24-70", mount: "RF", maxAperture: "2.8")
        
        let filmRoll = FilmRoll(name: "Portra 400", iso: 400, brand: "Kodak")
        
        var session1 = Session(
            title: "Summer Beach",
            date: Date(),
            location: "Bondi Beach, Sydney",
            note: "Beautiful sunset shoot",
            camera: camera1,
            lens: lens1
        )
        
        var session2 = Session(
            title: "Urban Exploration",
            date: Date().addingTimeInterval(-86400),
            location: "CBD",
            note: "Black and white street photography",
            camera: camera2,
            lens: lens2
        )
        
        var session3 = Session(
            title: "Film Photography",
            date: Date().addingTimeInterval(-172800),
            location: "Park",
            filmRoll: filmRoll
        )
        
        // Add mock photos
        let photo1 = Photo(
            imagePath: "Photos/photo1.jpg",
            note: "Golden hour shot",
            latitude: -33.8915,
            longitude: 151.2865,
            iso: 100,
            aperture: "2.0",
            shutterSpeed: "1/500",
            focalLength: "50"
        )
        
        let photo2 = Photo(
            imagePath: "Photos/photo2.jpg",
            note: "Candid moment",
            iso: 100,
            aperture: "2.8"
        )
        
        session1.photos = [photo1, photo2]
        session2.photos = [photo2]
        
        return [session1, session2, session3]
    }
}

/// Extension for generating mock camera gear
extension Camera {
    static func mockCameras() -> [Camera] {
        [
            Camera(brand: "Canon", model: "EOS R5", purchaseYear: 2021, notes: "Main mirrorless"),
            Camera(brand: "Leica", model: "M6", purchaseYear: 2019, notes: "Film camera"),
            Camera(brand: "Fujifilm", model: "X-T5", purchaseYear: 2023),
        ]
    }
}

extension Lens {
    static func mockLenses() -> [Lens] {
        [
            Lens(name: "50mm Prime", focalLength: "50", mount: "RF", maxAperture: "1.8", notes: "Standard prime"),
            Lens(name: "24-70mm Zoom", focalLength: "24-70", mount: "RF", maxAperture: "2.8", notes: "Versatile zoom"),
            Lens(name: "85mm Portrait", focalLength: "85", mount: "RF", maxAperture: "1.2", notes: "Portrait lens"),
        ]
    }
}

extension FilmRoll {
    static func mockFilmRolls() -> [FilmRoll] {
        [
            FilmRoll(name: "Portra 400", iso: 400, brand: "Kodak", status: .shooting),
            FilmRoll(name: "Superia 200", iso: 200, brand: "Fujifilm", status: .finished),
            FilmRoll(name: "HP5 Plus", iso: 400, brand: "Ilford", status: .developed),
        ]
    }
}
