import SwiftUI
import MapKit

// MARK: - Fish Map View (Tab)

/// Full-screen map of Saskatchewan showing fish locations at major water bodies.
/// Includes a province border outline and pins for each water body colored by fish density.
struct FishMapView: View {
    @State private var selectedWaterBody: WaterBody?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 54.0, longitude: -106.0),
            span: MKCoordinateSpan(latitudeDelta: 14.0, longitudeDelta: 14.0)
        )
    )

    private let waterBodies = SaskatchewanWaterBodies.all

    var body: some View {
        NavigationStack {
            ZStack {
                Color.screenBackground.ignoresSafeArea()

                Map(position: $cameraPosition, selection: $selectedWaterBody) {

                    // Saskatchewan province border outline
                    MapPolyline(coordinates: SaskatchewanBorder.coordinates)
                        .stroke(.white.opacity(0.7), lineWidth: 2)

                    // Water body pins
                    ForEach(waterBodies) { wb in
                        let fishCount = FishLocations.fishIds(atWaterBody: wb.id).count
                        Annotation(wb.name, coordinate: wb.coordinate, anchor: .bottom) {
                            WaterBodyPin(waterBody: wb, fishCount: fishCount)
                        }
                        .tag(wb)
                    }
                }
                .mapStyle(.imagery(elevation: .realistic))
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
            }
            .sheet(item: $selectedWaterBody) { wb in
                WaterBodyDetailSheet(waterBody: wb)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .navigationTitle("Saskatchewan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Water Body Pin

/// Custom map pin showing fish count with color based on density.
private struct WaterBodyPin: View {
    let waterBody: WaterBody
    let fishCount: Int

    private var pinColor: Color {
        switch fishCount {
        case 0...2:  return .rarityCommon
        case 3...5:  return .rarityUncommon
        case 6...8:  return .rarityRare
        case 9...12: return .rarityEpic
        default:     return .rarityLegendary
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(pinColor.gradient)
                    .frame(width: 36, height: 36)
                    .shadow(color: pinColor.opacity(0.6), radius: 4)

                Text("\(fishCount)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }

            // Pin tail
            Triangle()
                .fill(pinColor.gradient)
                .frame(width: 12, height: 8)
        }
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
        }
    }
}

// MARK: - Water Body Detail Sheet

/// Bottom sheet showing all fish found at a water body.
private struct WaterBodyDetailSheet: View {
    let waterBody: WaterBody

    private var fishAtLocation: [Fish] {
        FishLocations.fishIds(atWaterBody: waterBody.id)
            .compactMap { FishDatabase.fish(byId: $0) }
            .sorted { $0.id < $1.id }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack(spacing: 12) {
                        Image(systemName: iconForType)
                            .font(.title2)
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44)
                            .background(.blue.opacity(0.15))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(waterBody.name)
                                .font(.title3.bold())
                            Text("\(fishAtLocation.count) species found here")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    // Fish list
                    LazyVStack(spacing: 8) {
                        ForEach(fishAtLocation) { fish in
                            FishLocationRow(fish: fish)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
            }
            .background(Color.screenBackground)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var iconForType: String {
        switch waterBody.type {
        case .lake, .reservoir: return "water.waves"
        case .river:            return "arrow.left.arrow.right"
        case .creek:            return "drop.fill"
        case .region:           return "mappin.circle.fill"
        }
    }
}

// MARK: - Fish Location Row

private struct FishLocationRow: View {
    let fish: Fish

    var body: some View {
        HStack(spacing: 12) {
            // Fish image
            Image(fish.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(fish.rarityTier.swiftUIColor.opacity(0.5), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(fish.formattedId)
                        .font(.pixelFont(size: 11))
                        .foregroundStyle(fish.rarityTier.swiftUIColor)

                    Text(fish.commonName)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                }

                Text(fish.scientificName)
                    .font(.scientificName(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Rarity badge
            Text(fish.rarityTier.displayName)
                .font(.caption2.bold())
                .foregroundStyle(fish.rarityTier.swiftUIColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(fish.rarityTier.swiftUIColor.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.screenBackground.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Preview

#Preview("Fish Map") {
    FishMapView()
        .preferredColorScheme(.dark)
}
