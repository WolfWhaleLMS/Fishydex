import SwiftUI
import PhotosUI

/// Sheet for logging a new catch of a specific fish species.
///
/// Shows the fish name and image, a date picker, auto-filled GPS location,
/// photo picker, notes field, and a "Register Catch" button.
struct CatchLogView: View {
    let fish: Fish

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var caughtDate: Date = .now
    @State private var locationText: String = ""
    @State private var notes: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var isLoadingLocation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.screenBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Fish header
                        fishHeader

                        // Date picker
                        dateSection

                        // Location
                        locationSection

                        // Photo
                        photoSection

                        // Notes
                        notesSection

                        // Submit button
                        PokedexButton("Register Catch", icon: "checkmark.circle.fill") {
                            Task { await submitCatch() }
                        }
                        .disabled(isSubmitting)
                        .padding(.top, 8)

                        // Error
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 12))
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(PokedexLayout.screenPadding)
                }
            }
            .navigationTitle("Log Catch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.screenGlow)
                }
            }
            .toolbarBackground(Color.pokedexDarkRed, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            await loadCurrentLocation()
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }

    // MARK: - Fish Header

    private var fishHeader: some View {
        HStack(spacing: 14) {
            // Fish image
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.screenBackground)

                Image(fish.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
            .frame(width: 70, height: 70)
            .metallicBorder(cornerRadius: 10, lineWidth: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(fish.commonName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)

                Text(fish.scientificName)
                    .font(.scientificName(size: 13))
                    .foregroundStyle(.white.opacity(0.6))

                TypeBadge(category: fish.category, size: .compact)
            }

            Spacer()
        }
    }

    // MARK: - Date Section

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("DATE & TIME")

            DatePicker(
                "",
                selection: $caughtDate,
                in: ...Date.now,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(Color.screenGlow)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.screenBackground.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.screenGlow.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                fieldLabel("LOCATION")

                if isLoadingLocation {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(Color.screenGlow)
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.pokedexBlue)

                TextField("", text: $locationText, prompt:
                    Text("Enter location...")
                        .foregroundColor(Color.screenGlow.opacity(0.35))
                )
                .font(.dataReadout(size: 13))
                .foregroundStyle(.white)
                .tint(Color.screenGlow)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.screenBackground.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.screenGlow.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("PHOTO")

            if let photoData, let uiImage = UIImage(data: photoData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .metallicBorder(cornerRadius: 8, lineWidth: 2)

                    Button {
                        self.photoData = nil
                        selectedPhotoItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white, .black.opacity(0.6))
                    }
                    .padding(6)
                }
            } else {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.screenGlow.opacity(0.5))

                        Text("Add Photo")
                            .font(.dataReadout(size: 12))
                            .foregroundStyle(Color.screenGlow.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.screenBackground.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                Color.screenGlow.opacity(0.2),
                                style: StrokeStyle(lineWidth: 1, dash: [6])
                            )
                    )
                }
            }
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("NOTES")

            TextField("", text: $notes, prompt:
                Text("Add notes about your catch...")
                    .foregroundColor(Color.screenGlow.opacity(0.35)),
                axis: .vertical
            )
            .font(.system(size: 14))
            .foregroundStyle(.white)
            .tint(Color.screenGlow)
            .lineLimit(3...6)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.screenBackground.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.screenGlow.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Helpers

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.pixelFont(size: 10))
            .foregroundStyle(Color.screenGlow.opacity(0.6))
    }

    private func loadCurrentLocation() async {
        isLoadingLocation = true
        let locationService = LocationService()
        await locationService.requestPermission()

        do {
            let location = try await locationService.currentLocation()
            let name = try await locationService.locationName(for: location)
            locationText = name
        } catch {
            // Silently fail — user can type manually
        }

        isLoadingLocation = false
    }

    private func submitCatch() async {
        isSubmitting = true
        errorMessage = nil

        do {
            let catchService = CatchService(modelContainer: modelContext.container)
            try await catchService.logCatch(
                fishId: fish.id,
                locationName: locationText.isEmpty ? nil : locationText,
                photoData: photoData,
                notes: notes.isEmpty ? nil : notes
            )

            HapticsService.catchFeedback()
            dismiss()
        } catch {
            errorMessage = "Failed to log catch: \(error.localizedDescription)"
        }

        isSubmitting = false
    }
}

// MARK: - Preview

#Preview("Catch Log") {
    CatchLogView(fish: Fish(
        id: 34,
        commonName: "Northern Pike",
        scientificName: "Esox lucius",
        family: "Esocidae",
        familyCommonName: "Pikes",
        category: .sportFish,
        rarityTier: .common,
        conservationStatus: "S5 (secure)",
        cosewicStatus: nil,
        sizeRange: "50-120 cm",
        maxWeight: "19+ kg",
        description: "A premier sport fish.",
        habitat: "Lakes and rivers.",
        funFact: nil,
        isNative: true
    ))
    .modelContainer(for: [CatchRecord.self, DiscoveryState.self], inMemory: true)
}
