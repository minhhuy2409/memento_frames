import SwiftUI
import SwiftData

/// View for editing an existing photography session with premium forms
struct EditSessionView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let session: Session
    
    @State private var title: String
    @State private var location: String
    @State private var note: String
    @State private var date: Date
    @State private var selectedCamera: Camera?
    @State private var selectedLens: Lens?
    @State private var selectedFilmRoll: FilmRoll?
    
    @Query(sort: \Camera.brand) private var availableCameras: [Camera]
    @Query(sort: \Lens.focalLength) private var availableLenses: [Lens]
    @Query(sort: \FilmRoll.name) private var availableFilmRolls: [FilmRoll]
    
    init(session: Session) {
        self.session = session
        _title = State(initialValue: session.title)
        _location = State(initialValue: session.location)
        _note = State(initialValue: session.note)
        _date = State(initialValue: session.date)
        _selectedCamera = State(initialValue: session.camera)
        _selectedLens = State(initialValue: session.lens)
        _selectedFilmRoll = State(initialValue: session.filmRoll)
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Theme background
                (colorScheme == .dark ? Color.photoBackgroundDark : Color.photoBackgroundLight)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Section 1: Details
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("EDIT DETAILS", icon: "pencil.line")
                            
                            GlassCardView {
                                VStack(spacing: 16) {
                                    FormField(label: "Title", text: $title, placeholder: "Enter session title")
                                    FormField(label: "Location", text: $location, placeholder: "Enter location")
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("DATE")
                                            .font(.system(size: 11, weight: .bold, design: .serif))
                                            .tracking(1.2)
                                            .foregroundColor(.secondary)
                                        
                                        DatePicker("Select Date", selection: $date, displayedComponents: .date)
                                            .datePickerStyle(.compact)
                                            .tint(.photoAccent)
                                    }
                                }
                                .padding(16)
                            }
                        }
                        
                        // Section 2: Notes
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("SESSION NOTES", icon: "note.text")
                            
                            GlassCardView {
                                FormField(
                                    label: "Notes",
                                    text: $note,
                                    placeholder: "Record notes about this session",
                                    isMultiline: true
                                )
                                .padding(16)
                            }
                        }
                        
                        // Section 3: Gear Assignment
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader("GEAR ASSIGNED", icon: "camera.fill")
                            
                            GlassCardView {
                                VStack(spacing: 14) {
                                    // Camera Picker
                                    Picker("Camera", selection: $selectedCamera) {
                                        Text("None assigned").tag(nil as Camera?)
                                        ForEach(availableCameras, id: \.id) { camera in
                                            Text(camera.displayName).tag(camera as Camera?)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    
                                    Divider()
                                        .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                                    
                                    // Lens Picker
                                    Picker("Lens", selection: $selectedLens) {
                                        Text("None assigned").tag(nil as Lens?)
                                        ForEach(availableLenses, id: \.id) { lens in
                                            Text(lens.displayName).tag(lens as Lens?)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    
                                    // Film Roll Picker (if Film Mode is enabled)
                                    if UserDefaults.standard.bool(forKey: "isFilmModeEnabled") {
                                        Divider()
                                            .background(colorScheme == .dark ? Color.photoBorderDark : Color.photoBorderLight)
                                        
                                        Picker("Film Roll", selection: $selectedFilmRoll) {
                                            Text("None assigned").tag(nil as FilmRoll?)
                                            ForEach(availableFilmRolls, id: \.id) { filmRoll in
                                                Text(filmRoll.name).tag(filmRoll as FilmRoll?)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                    }
                                }
                                .padding(16)
                            }
                        }
                        
                        // Save Button
                        Button(action: {
                            HapticService.success()
                            saveSession()
                            dismiss()
                        }) {
                            Text("SAVE CHANGES")
                                .font(.system(size: 13, weight: .bold, design: .serif))
                                .tracking(1.5)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                        }
                        .disabled(!isFormValid)
                        .padding(14)
                        .background(isFormValid ? Color.photoAccent : Color.photoAccent.opacity(0.35))
                        .cornerRadius(16)
                        .shadow(color: Color.photoAccent.opacity(isFormValid ? 0.35 : 0), radius: 8, x: 0, y: 4)
                        .buttonStyle(EditButtonStyle())
                        .padding(.top, 10)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Edit Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        HapticService.lightImpact()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveSession() {
        session.title = title.trimmingCharacters(in: .whitespaces)
        session.location = location.trimmingCharacters(in: .whitespaces)
        session.note = note.trimmingCharacters(in: .whitespaces)
        session.date = date
        session.camera = selectedCamera
        session.lens = selectedLens
        session.filmRoll = selectedFilmRoll
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save edited session: \(error.localizedDescription)")
        }
    }
}

private struct EditButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.premiumSpring, value: configuration.isPressed)
    }
}

#Preview {
    let mockSession = Session(title: "Preview Session")
    return EditSessionView(session: mockSession)
        .modelContainer(for: [Session.self, Camera.self, Lens.self, Photo.self, FilmRoll.self], inMemory: true)
}
