import SwiftUI
import RealityKit
import ARKit

// MARK: - ARContainerView

/// UIViewRepresentable wrapper around a RealityKit `ARView` that detects horizontal planes
/// and places a fish info card entity in the real world.
struct ARContainerView: UIViewRepresentable {

    let fish: Fish

    /// Called when a plane is detected and the card has been placed.
    var onCardPlaced: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(fish: fish, onCardPlaced: onCardPlaced)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Configure AR session for horizontal plane detection
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic

        arView.session.run(config)
        arView.session.delegate = context.coordinator
        context.coordinator.arView = arView

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Update fish reference if it changes
        context.coordinator.fish = fish
    }

    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        uiView.session.pause()
        coordinator.arView = nil
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, ARSessionDelegate, @unchecked Sendable {

        var fish: Fish
        weak var arView: ARView?
        private var hasPlacedCard: Bool = false
        private nonisolated(unsafe) var onCardPlaced: (() -> Void)?

        init(fish: Fish, onCardPlaced: (() -> Void)?) {
            self.fish = fish
            self.onCardPlaced = onCardPlaced
        }

        // MARK: - ARSessionDelegate

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard !hasPlacedCard else { return }

            for anchor in anchors {
                guard let planeAnchor = anchor as? ARPlaneAnchor,
                      planeAnchor.alignment == .horizontal else { continue }

                placeFishCard(at: planeAnchor)
                hasPlacedCard = true

                Task { @MainActor in
                    self.onCardPlaced?()
                    HapticsService.revealFeedback()
                }
                break
            }
        }

        // MARK: - Card Placement

        private func placeFishCard(at anchor: ARPlaneAnchor) {
            guard let arView else { return }

            // Create the card entity
            let cardEntity = createCardEntity()

            // Create an anchor entity at the detected plane
            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.addChild(cardEntity)

            // Position the card slightly above the surface
            cardEntity.position = SIMD3<Float>(0, 0.05, 0)

            // Add slow rotation animation
            addRotationAnimation(to: cardEntity)

            arView.scene.addAnchor(anchorEntity)
        }

        /// Creates a flat card entity with a fish info texture.
        private func createCardEntity() -> ModelEntity {
            // Card dimensions (20cm x 28cm — roughly a trading card aspect ratio)
            let cardWidth: Float = 0.20
            let cardHeight: Float = 0.28

            // Create a plane mesh for the card
            let mesh = MeshResource.generatePlane(width: cardWidth, height: cardHeight)

            // Generate the card texture from a SwiftUI snapshot
            let material: SimpleMaterial
            if let texture = renderCardTexture() {
                var mat = SimpleMaterial()
                mat.color = .init(texture: .init(texture))
                mat.metallic = .float(0.1)
                mat.roughness = .float(0.8)
                material = mat
            } else {
                // Fallback: solid color with rarity tint
                let rarityColor = fish.rarityTier.color
                var mat = SimpleMaterial()
                mat.color = .init(
                    tint: .init(
                        red: CGFloat(rarityColor.r),
                        green: CGFloat(rarityColor.g),
                        blue: CGFloat(rarityColor.b),
                        alpha: 1.0
                    )
                )
                material = mat
            }

            let entity = ModelEntity(mesh: mesh, materials: [material])

            // Rotate so the card faces up (readable when looking down at a table)
            entity.orientation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))

            return entity
        }

        /// Renders the fish card info as a texture using Core Graphics.
        private func renderCardTexture() -> TextureResource? {
            let width = 400
            let height = 560
            let size = CGSize(width: width, height: height)

            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { ctx in
                let rect = CGRect(origin: .zero, size: size)
                let context = ctx.cgContext

                // Background
                UIColor(red: 0.102, green: 0.102, blue: 0.180, alpha: 1.0).setFill()
                context.fill(rect)

                // Border with rarity color
                let rarityUIColor = UIColor(
                    red: fish.rarityTier.color.r,
                    green: fish.rarityTier.color.g,
                    blue: fish.rarityTier.color.b,
                    alpha: 1.0
                )
                rarityUIColor.setStroke()
                context.setLineWidth(6)
                let borderRect = rect.insetBy(dx: 3, dy: 3)
                let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: 16)
                borderPath.stroke()

                // Entry number
                let numberAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 28, weight: .bold),
                    .foregroundColor: UIColor(red: 0, green: 1.0, blue: 0.255, alpha: 1.0)
                ]
                let numberString = fish.formattedId as NSString
                numberString.draw(at: CGPoint(x: 20, y: 20), withAttributes: numberAttrs)

                // Rarity badge
                let rarityAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 16, weight: .semibold),
                    .foregroundColor: rarityUIColor
                ]
                let rarityString = fish.rarityTier.displayName.uppercased() as NSString
                let raritySize = rarityString.size(withAttributes: rarityAttrs)
                rarityString.draw(
                    at: CGPoint(x: CGFloat(width) - raritySize.width - 20, y: 24),
                    withAttributes: rarityAttrs
                )

                // Fish image placeholder area
                let imageRect = CGRect(x: 40, y: 70, width: CGFloat(width) - 80, height: 200)
                UIColor(white: 0.15, alpha: 1.0).setFill()
                UIBezierPath(roundedRect: imageRect, cornerRadius: 10).fill()

                // Fish icon placeholder
                let fishIcon = UIImage(systemName: "fish.fill")?.withTintColor(.white.withAlphaComponent(0.3), renderingMode: .alwaysOriginal)
                let iconSize = CGSize(width: 60, height: 60)
                let iconOrigin = CGPoint(
                    x: imageRect.midX - iconSize.width / 2,
                    y: imageRect.midY - iconSize.height / 2
                )
                fishIcon?.draw(in: CGRect(origin: iconOrigin, size: iconSize))

                // Common name
                let nameAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 26, weight: .bold),
                    .foregroundColor: UIColor.white
                ]
                let nameString = fish.commonName as NSString
                nameString.draw(at: CGPoint(x: 20, y: 290), withAttributes: nameAttrs)

                // Scientific name
                let sciAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.italicSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.6)
                ]
                let sciString = fish.scientificName as NSString
                sciString.draw(at: CGPoint(x: 20, y: 325), withAttributes: sciAttrs)

                // Divider line
                context.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
                context.setLineWidth(1)
                context.move(to: CGPoint(x: 20, y: 360))
                context.addLine(to: CGPoint(x: CGFloat(width) - 20, y: 360))
                context.strokePath()

                // Stats
                let statAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .medium),
                    .foregroundColor: UIColor(red: 0, green: 1.0, blue: 0.255, alpha: 0.8)
                ]

                let stats: [(String, String)] = [
                    ("FAMILY", fish.familyCommonName),
                    ("SIZE", fish.sizeRange),
                    ("TYPE", fish.category.rawValue),
                    ("STATUS", fish.isNative ? "Native" : "Non-native")
                ]

                var yOffset: CGFloat = 375
                for (label, value) in stats {
                    let labelAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.monospacedSystemFont(ofSize: 11, weight: .bold),
                        .foregroundColor: UIColor(red: 0, green: 1.0, blue: 0.255, alpha: 0.5)
                    ]
                    (label as NSString).draw(at: CGPoint(x: 20, y: yOffset), withAttributes: labelAttrs)
                    (value as NSString).draw(at: CGPoint(x: 20, y: yOffset + 16), withAttributes: statAttrs)
                    yOffset += 42
                }
            }

            // Convert UIImage to TextureResource
            guard let cgImage = image.cgImage else { return nil }
            return try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
        }

        /// Adds a slow Y-axis rotation animation to the card.
        private func addRotationAnimation(to entity: ModelEntity) {
            // Rotate 360 degrees over 20 seconds
            let rotation = simd_quatf(angle: .pi * 2, axis: SIMD3<Float>(0, 1, 0))
            let currentOrientation = entity.orientation
            let targetOrientation = rotation * currentOrientation

            entity.move(
                to: Transform(
                    scale: entity.scale,
                    rotation: targetOrientation,
                    translation: entity.position
                ),
                relativeTo: entity.parent,
                duration: 20.0
            )

            // Note: For a continuous rotation, the hosting view should re-trigger
            // this animation periodically. RealityKit doesn't natively support
            // infinite animations on transforms.
        }
    }
}

// MARK: - Preview

#Preview("AR Container") {
    // AR requires a physical device — this preview is a placeholder.
    ZStack {
        Color.screenBackground.ignoresSafeArea()
        Text("AR Preview — run on device")
            .foregroundStyle(.white.opacity(0.5))
    }
}
