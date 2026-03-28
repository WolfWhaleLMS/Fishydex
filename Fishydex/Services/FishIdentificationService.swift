import Foundation
import UIKit
import CoreLocation

// MARK: - FishIdentificationService

/// Maps iNaturalist identification results to Fishface fish entries.
/// Matches by scientific name, falling back to common name fuzzy matching.
actor FishIdentificationService {

    // MARK: - Types

    struct Match: Sendable {
        let fish: Fish
        let confidence: Double      // 0-1 scale
        let source: MatchSource

        enum MatchSource: Sendable {
            case exactScientific     // Scientific name matched exactly
            case partialScientific   // Genus matched
            case commonName          // Common name matched
        }
    }

    enum IdentificationState: Sendable {
        case idle
        case analyzing
        case identified([Match])
        case failed(String)
        case noMatch
    }

    // MARK: - Properties

    private let iNatService: INaturalistService
    private let allFish: [Fish]

    /// Lookup table: lowercase scientific name → Fish
    private let scientificNameIndex: [String: Fish]

    /// Lookup table: lowercase common name → Fish
    private let commonNameIndex: [String: Fish]

    /// Lookup table: lowercase genus → [Fish]
    private let genusIndex: [String: [Fish]]

    // MARK: - Init

    init(iNatService: INaturalistService) {
        self.iNatService = iNatService
        self.allFish = FishDatabase.allFish

        var sciIndex: [String: Fish] = [:]
        var comIndex: [String: Fish] = [:]
        var genIndex: [String: [Fish]] = [:]

        for fish in FishDatabase.allFish {
            // Index by full scientific name (lowercase)
            sciIndex[fish.scientificName.lowercased()] = fish

            // Index by common name (lowercase)
            comIndex[fish.commonName.lowercased()] = fish

            // Index by genus (first word of scientific name)
            let genus = fish.scientificName.split(separator: " ").first
                .map { String($0).lowercased() } ?? ""
            genIndex[genus, default: []].append(fish)
        }

        self.scientificNameIndex = sciIndex
        self.commonNameIndex = comIndex
        self.genusIndex = genIndex
    }

    // MARK: - Identification

    /// Identify a fish from a photo. Returns matched Fishface entries ranked by confidence.
    func identify(
        image: UIImage,
        location: CLLocation? = nil
    ) async -> IdentificationState {

        let results: [INaturalistService.IdentificationResult]
        do {
            results = try await iNatService.identifyFish(
                image: image,
                latitude: location?.coordinate.latitude,
                longitude: location?.coordinate.longitude
            )
        } catch let error as INaturalistService.IdentificationError {
            return .failed(error.localizedDescription)
        } catch {
            return .failed("Network error: \(error.localizedDescription)")
        }

        // Map iNaturalist results to Fishface entries
        var matches: [Match] = []

        for result in results {
            if let match = matchToFishface(result) {
                matches.append(match)
            }
        }

        if matches.isEmpty {
            return .noMatch
        }

        return .identified(matches)
    }

    // MARK: - Matching Logic

    /// Try to match an iNaturalist result to a Fishface fish entry.
    private func matchToFishface(_ result: INaturalistService.IdentificationResult) -> Match? {
        let sciName = result.scientificName.lowercased()
        let comName = result.commonName.lowercased()

        // 1. Exact scientific name match
        if let fish = scientificNameIndex[sciName] {
            return Match(
                fish: fish,
                confidence: result.score / 100.0,
                source: .exactScientific
            )
        }

        // 2. Check common synonyms (some species have been reclassified)
        if let fish = matchSynonym(sciName) {
            return Match(
                fish: fish,
                confidence: result.score / 100.0,
                source: .exactScientific
            )
        }

        // 3. Genus-level match (same genus, might be a subspecies or related)
        let genus = sciName.split(separator: " ").first.map(String.init) ?? ""
        if let genusFish = genusIndex[genus], genusFish.count == 1 {
            // Only one species in this genus in SK — likely a match
            return Match(
                fish: genusFish[0],
                confidence: (result.score / 100.0) * 0.8, // Reduce confidence
                source: .partialScientific
            )
        }

        // 4. Common name match
        if let fish = commonNameIndex[comName] {
            return Match(
                fish: fish,
                confidence: (result.score / 100.0) * 0.9,
                source: .commonName
            )
        }

        // 5. Partial common name match (e.g., "Northern Pike" in "Northern pike")
        for (name, fish) in commonNameIndex {
            if comName.contains(name) || name.contains(comName) {
                return Match(
                    fish: fish,
                    confidence: (result.score / 100.0) * 0.7,
                    source: .commonName
                )
            }
        }

        return nil
    }

    /// Handle taxonomic synonyms for reclassified species.
    private func matchSynonym(_ scientificName: String) -> Fish? {
        // Common synonyms for Saskatchewan fish
        let synonyms: [String: String] = [
            // Sand Shiner reclassified
            "notropis stramineus": "miniellus stramineus",
            // River Shiner synonym
            "alburnops blennius": "notropis blennius",
            // Weed Shiner synonym
            "alburnops texanus": "notropis texanus",
            // Spottail Shiner synonym
            "hudsonius hudsonius": "notropis hudsonius",
            // Mimic Shiner synonym
            "paranotropis volucellus": "notropis volucellus",
            // Plains Sucker synonym
            "pantosteus platyrhynchus": "catostomus platyrhynchus",
            // Cutthroat Trout old name
            "oncorhynchus clarkii": "oncorhynchus virginalis",
            "oncorhynchus clarki": "oncorhynchus virginalis",
            // Western Blacknose Dace
            "rhinichthys atratulus": "rhinichthys obtusus",
        ]

        if let canonicalName = synonyms[scientificName] {
            return scientificNameIndex[canonicalName]
        }

        return nil
    }
}
