import SwiftUI
import SwiftData

/// Gear management view for cameras, lenses, and film rolls
struct GearView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: CameraGearViewModel
    
    // Add sheets state
    @State private var showAddCamera = false
    @State private var showAddLens = false
    @State private var showAddFilmRoll = false
    
    // Edit sheets state
    @State private var editingCamera: Camera? = nil
    @State private var editingLens: Lens? = nil
    @State private var editingFilmRoll: FilmRoll? = nil
    
    // Camera Form fields
    @State private var cameraBrand = ""
    @State private var cameraModel = ""
    @State private var cameraPurchaseYear = ""
    @State private var cameraNotes = ""
    
    // Lens Form fields
    @State private var lensName = ""
    @State private var lensFocalLength = ""
    @State private var lensMount = ""
    @State private var lensAperture = ""
    @State private var lensNotes = ""
    
    // Film Roll Form fields
    @State private var filmName = ""
    @State private var filmBrand = ""
    @State private var filmISO = "400"
    @State private var filmCurrentFrame = "0"
    @State private var filmMaxFrame = "36"
    @State private var filmStatus: FilmRollStatus = .shooting
    @State private var filmNotes = ""
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: CameraGearViewModel(modelContext: modelContext))
    }
    
    var isFilmModeEnabled: Bool {
        UserDefaults.standard.bool(forKey: "isFilmModeEnabled")
    }
    
    var body: some View {
        ZStack {
                // Theme background
                (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // CAMERAS SECTION
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                SectionHeader("CAMERAS", icon: "camera.fill")
                                Spacer()
                                Button(action: {
                                    HapticService.lightImpact()
                                    showAddCamera = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.photoAccent)
                                }
                            }
                            
                            if viewModel.cameras.isEmpty {
                                GlassCardView {
                                    Text("No cameras added to your gear portfolio yet.")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            } else {
                                ForEach(viewModel.cameras) { camera in
                                    GearCardView(item: .camera(camera))
                                        .contextMenu {
                                            Button {
                                                HapticService.lightImpact()
                                                prepareEditCamera(camera)
                                            } label: {
                                                Label("Edit Camera", systemImage: "pencil")
                                            }
                                            
                                            Button(role: .destructive) {
                                                HapticService.heavyImpact()
                                                viewModel.deleteCamera(camera)
                                            } label: {
                                                Label("Delete Camera", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                        
                        // LENSES SECTION
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                SectionHeader("LENSES", icon: "camera.macro")
                                Spacer()
                                Button(action: {
                                    HapticService.lightImpact()
                                    showAddLens = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.photoAccent)
                                }
                            }
                            
                            if viewModel.lenses.isEmpty {
                                GlassCardView {
                                    Text("No lenses added to your gear portfolio yet.")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            } else {
                                ForEach(viewModel.lenses) { lens in
                                    GearCardView(item: .lens(lens))
                                        .contextMenu {
                                            Button {
                                                HapticService.lightImpact()
                                                prepareEditLens(lens)
                                            } label: {
                                                Label("Edit Lens", systemImage: "pencil")
                                            }
                                            
                                            Button(role: .destructive) {
                                                HapticService.heavyImpact()
                                                viewModel.deleteLens(lens)
                                            } label: {
                                                Label("Delete Lens", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                        
                        // FILM ROLLS SECTION (Conditional on settings)
                        if isFilmModeEnabled {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    SectionHeader("FILM ROLLS", icon: "film.fill")
                                    Spacer()
                                    Button(action: {
                                        HapticService.lightImpact()
                                        showAddFilmRoll = true
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.photoAccent)
                                    }
                                }
                                
                                if viewModel.filmRolls.isEmpty {
                                    GlassCardView {
                                        Text("No active film rolls in catalog.")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                } else {
                                    ForEach(viewModel.filmRolls) { filmRoll in
                                        GearCardView(item: .filmRoll(filmRoll))
                                            .contextMenu {
                                                Button {
                                                    HapticService.lightImpact()
                                                    prepareEditFilmRoll(filmRoll)
                                                } label: {
                                                    Label("Edit Film Roll", systemImage: "pencil")
                                                }
                                                
                                                Button(role: .destructive) {
                                                    HapticService.heavyImpact()
                                                    viewModel.deleteFilmRoll(filmRoll)
                                                } label: {
                                                    Label("Delete Film Roll", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
        }
        .navigationTitle("Gear Portfolio")
        .navigationBarTitleDisplayMode(.large)
        
        // Camera Sheet Add
        .sheet(isPresented: $showAddCamera) {
            cameraFormSheet(isEdit: false)
        }
        // Camera Sheet Edit
        .sheet(item: $editingCamera) { _ in
            cameraFormSheet(isEdit: true)
        }
        // Lens Sheet Add
        .sheet(isPresented: $showAddLens) {
            lensFormSheet(isEdit: false)
        }
        // Lens Sheet Edit
        .sheet(item: $editingLens) { _ in
            lensFormSheet(isEdit: true)
        }
        // Film Roll Sheet Add
        .sheet(isPresented: $showAddFilmRoll) {
            filmRollFormSheet(isEdit: false)
        }
        // Film Roll Sheet Edit
        .sheet(item: $editingFilmRoll) { _ in
            filmRollFormSheet(isEdit: true)
        }
    }
    
    // MARK: - Camera Sheet Builder
    @ViewBuilder
    private func cameraFormSheet(isEdit: Bool) -> some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        GlassCardView {
                            VStack(spacing: 16) {
                                FormField(label: "Brand", text: $cameraBrand, placeholder: "e.g. Leica, Fujifilm, Canon")
                                FormField(label: "Model", text: $cameraModel, placeholder: "e.g. M11, X-T5, EOS R5")
                                FormField(label: "Purchase Year (Optional)", text: $cameraPurchaseYear, placeholder: "e.g. 2024")
                                    .keyboardType(.numberPad)
                            }
                            .padding(16)
                        }
                        
                        GlassCardView {
                            VStack(spacing: 16) {
                                FormField(label: "Notes", text: $cameraNotes, placeholder: "Describe configuration notes, mount style, etc.", isMultiline: true)
                            }
                            .padding(16)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(isEdit ? "Edit Camera" : "Add Camera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        HapticService.lightImpact()
                        resetCameraForm()
                        showAddCamera = false
                        editingCamera = nil
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEdit ? "Save" : "Add") {
                        HapticService.success()
                        let year = Int(cameraPurchaseYear)
                        if isEdit, let camera = editingCamera {
                            viewModel.updateCamera(camera, brand: cameraBrand, model: cameraModel, purchaseYear: year, notes: cameraNotes)
                        } else {
                            viewModel.addCamera(brand: cameraBrand, model: cameraModel, purchaseYear: year, notes: cameraNotes)
                        }
                        resetCameraForm()
                        showAddCamera = false
                        editingCamera = nil
                    }
                    .disabled(cameraBrand.isEmpty || cameraModel.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Lens Sheet Builder
    @ViewBuilder
    private func lensFormSheet(isEdit: Bool) -> some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        GlassCardView {
                            VStack(spacing: 16) {
                                FormField(label: "Name (Optional)", text: $lensName, placeholder: "e.g. Summicron 35mm f/2")
                                FormField(label: "Focal Length (mm)", text: $lensFocalLength, placeholder: "e.g. 35, 50, 85")
                                FormField(label: "Mount", text: $lensMount, placeholder: "e.g. M Mount, X Mount, RF Mount")
                                FormField(label: "Max Aperture (f/)", text: $lensAperture, placeholder: "e.g. 1.4, 2.0, 2.8")
                            }
                            .padding(16)
                        }
                        
                        GlassCardView {
                            VStack(spacing: 16) {
                                FormField(label: "Notes", text: $lensNotes, placeholder: "Notes on lens glass quality, filter sizes, etc.", isMultiline: true)
                            }
                            .padding(16)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(isEdit ? "Edit Lens" : "Add Lens")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        HapticService.lightImpact()
                        resetLensForm()
                        showAddLens = false
                        editingLens = nil
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEdit ? "Save" : "Add") {
                        HapticService.success()
                        if isEdit, let lens = editingLens {
                            viewModel.updateLens(lens, name: lensName, focalLength: lensFocalLength, mount: lensMount, maxAperture: lensAperture, notes: lensNotes)
                        } else {
                            viewModel.addLens(name: lensName, focalLength: lensFocalLength, mount: lensMount, maxAperture: lensAperture, notes: lensNotes)
                        }
                        resetLensForm()
                        showAddLens = false
                        editingLens = nil
                    }
                    .disabled(lensFocalLength.isEmpty || lensMount.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Film Roll Sheet Builder
    @ViewBuilder
    private func filmRollFormSheet(isEdit: Bool) -> some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        GlassCardView {
                            VStack(spacing: 16) {
                                FormField(label: "Brand", text: $filmBrand, placeholder: "e.g. Kodak, Fujifilm, Ilford")
                                FormField(label: "Name", text: $filmName, placeholder: "e.g. Portra 400, HP5 Plus")
                                FormField(label: "ISO", text: $filmISO, placeholder: "e.g. 400, 160, 3200")
                                    .keyboardType(.numberPad)
                            }
                            .padding(16)
                        }
                        
                        GlassCardView {
                            VStack(spacing: 16) {
                                FormField(label: "Current Frame", text: $filmCurrentFrame, placeholder: "e.g. 0, 12")
                                    .keyboardType(.numberPad)
                                FormField(label: "Max Frames", text: $filmMaxFrame, placeholder: "e.g. 36, 24, 12")
                                    .keyboardType(.numberPad)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("STATUS")
                                        .font(.system(size: 11, weight: .bold, design: .serif))
                                        .tracking(1.2)
                                        .foregroundColor(.secondary)
                                    
                                    Picker("Status", selection: $filmStatus) {
                                        ForEach(FilmRollStatus.allCases, id: \.self) { status in
                                            Text(status.rawValue.capitalized).tag(status)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                            .padding(16)
                        }
                        
                        GlassCardView {
                            VStack(spacing: 16) {
                                FormField(label: "Notes", text: $filmNotes, placeholder: "Describe developers used, push/pull details, etc.", isMultiline: true)
                            }
                            .padding(16)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(isEdit ? "Edit Film Roll" : "Add Film Roll")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        HapticService.lightImpact()
                        resetFilmRollForm()
                        showAddFilmRoll = false
                        editingFilmRoll = nil
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEdit ? "Save" : "Add") {
                        HapticService.success()
                        let iso = Int(filmISO) ?? 400
                        let currFrame = Int(filmCurrentFrame) ?? 0
                        let maxFrame = Int(filmMaxFrame) ?? 36
                        if isEdit, let roll = editingFilmRoll {
                            viewModel.updateFilmRoll(roll, name: filmName, iso: iso, brand: filmBrand, currentFrame: currFrame, maxFrame: maxFrame, status: filmStatus, notes: filmNotes)
                        } else {
                            viewModel.addFilmRoll(name: filmName, iso: iso, brand: filmBrand, currentFrame: currFrame, maxFrame: maxFrame, status: filmStatus, notes: filmNotes)
                        }
                        resetFilmRollForm()
                        showAddFilmRoll = false
                        editingFilmRoll = nil
                    }
                    .disabled(filmBrand.isEmpty || filmName.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Form Helper Preparations
    private func prepareEditCamera(_ camera: Camera) {
        cameraBrand = camera.brand
        cameraModel = camera.model
        cameraPurchaseYear = camera.purchaseYear != nil ? String(camera.purchaseYear!) : ""
        cameraNotes = camera.notes
        editingCamera = camera
    }
    
    private func prepareEditLens(_ lens: Lens) {
        lensName = lens.name
        lensFocalLength = lens.focalLength
        lensMount = lens.mount
        lensAperture = lens.maxAperture
        lensNotes = lens.notes
        editingLens = lens
    }
    
    private func prepareEditFilmRoll(_ film: FilmRoll) {
        filmName = film.name
        filmBrand = film.brand
        filmISO = String(film.iso)
        filmCurrentFrame = String(film.currentFrame)
        filmMaxFrame = String(film.maxFrame)
        filmStatus = film.status
        filmNotes = film.notes
        editingFilmRoll = film
    }
    
    // MARK: - Reset Helpers
    private func resetCameraForm() {
        cameraBrand = ""
        cameraModel = ""
        cameraPurchaseYear = ""
        cameraNotes = ""
    }
    
    private func resetLensForm() {
        lensName = ""
        lensFocalLength = ""
        lensMount = ""
        lensAperture = ""
        lensNotes = ""
    }
    
    private func resetFilmRollForm() {
        filmName = ""
        filmBrand = ""
        filmISO = "400"
        filmCurrentFrame = "0"
        filmMaxFrame = "36"
        filmStatus = .shooting
        filmNotes = ""
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Session.self, Camera.self, Lens.self, Photo.self, FilmRoll.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return GearView(modelContext: container.mainContext)
        .modelContainer(container)
}
