import Foundation
import UIKit

// MARK: - INaturalistService

/// Handles communication with iNaturalist's taxa suggestion API for fish identification.
/// Uses the /v1/taxa/suggest endpoint with source=visual.
actor INaturalistService {

    // MARK: - Types

    struct IdentificationResult: Sendable {
        let scientificName: String
        let commonName: String
        let score: Double
        let taxonId: Int
        let photoURL: String?
    }

    enum IdentificationError: LocalizedError {
        case noToken
        case imageCompressionFailed
        case networkError(Error)
        case invalidResponse
        case noResults
        case rateLimited

        var errorDescription: String? {
            switch self {
            case .noToken: return "Not authenticated with iNaturalist"
            case .imageCompressionFailed: return "Failed to compress image for upload"
            case .networkError(let error): return "Network error: \(error.localizedDescription)"
            case .invalidResponse: return "Invalid response from iNaturalist"
            case .noResults: return "No fish species identified"
            case .rateLimited: return "Too many requests — try again in a moment"
            }
        }
    }

    // MARK: - Properties

    private var apiToken: String?
    private let session: URLSession
    private let baseURL = "https://api.inaturalist.org/v1"

    // Actinopterygii (ray-finned fishes) iconic taxon ID
    private let fishTaxonId = 47178

    // MARK: - Init

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Authentication

    /// Set the JWT token obtained from iNaturalist OAuth flow.
    func setToken(_ token: String) {
        self.apiToken = token
    }

    /// Exchange an OAuth bearer token for a JWT API token.
    func exchangeOAuthToken(_ bearerToken: String) async throws {
        var request = URLRequest(url: URL(string: "https://www.inaturalist.org/users/api_token")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw IdentificationError.invalidResponse
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let token = json?["api_token"] as? String else {
            throw IdentificationError.invalidResponse
        }

        self.apiToken = token
    }

    var isAuthenticated: Bool {
        apiToken != nil
    }

    // MARK: - Species Identification

    /// Identify a fish species from a photo.
    /// Returns ranked results matching fish taxa, best match first.
    func identifyFish(
        image: UIImage,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) async throws -> [IdentificationResult] {

        // Compress image to JPEG (medium quality, reasonable size for upload)
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw IdentificationError.imageCompressionFailed
        }

        // Build multipart form data
        let boundary = "Fishydex-\(UUID().uuidString)"
        var body = Data()

        // Image field
        body.appendMultipart(boundary: boundary, name: "image",
                             filename: "fish.jpg", mimeType: "image/jpeg",
                             data: imageData)

        // Source = visual (triggers computer vision)
        body.appendMultipartField(boundary: boundary, name: "source", value: "visual")

        // Locale for English common names
        body.appendMultipartField(boundary: boundary, name: "locale", value: "en")

        // Filter to fish (Actinopterygii)
        body.appendMultipartField(boundary: boundary, name: "taxon_id", value: "\(fishTaxonId)")

        // Add location if available (improves accuracy via geomodel)
        if let lat = latitude {
            body.appendMultipartField(boundary: boundary, name: "lat", value: "\(lat)")
        }
        if let lng = longitude {
            body.appendMultipartField(boundary: boundary, name: "lng", value: "\(lng)")
        }

        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Build request
        var request = URLRequest(url: URL(string: "\(baseURL)/taxa/suggest")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body

        // Add auth token if available
        if let token = apiToken {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }

        // Send request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw IdentificationError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw IdentificationError.invalidResponse
        }

        if httpResponse.statusCode == 429 {
            throw IdentificationError.rateLimited
        }

        guard httpResponse.statusCode == 200 else {
            throw IdentificationError.invalidResponse
        }

        // Parse response
        return try parseResults(data)
    }

    // MARK: - Response Parsing

    private func parseResults(_ data: Data) throws -> [IdentificationResult] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            throw IdentificationError.invalidResponse
        }

        let identifications: [IdentificationResult] = results.compactMap { result in
            guard let taxon = result["taxon"] as? [String: Any],
                  let taxonId = taxon["id"] as? Int,
                  let scientificName = taxon["name"] as? String else {
                return nil
            }

            // Only include species-level results (rank_level 10)
            let rankLevel = taxon["rank_level"] as? Int ?? 100
            guard rankLevel <= 20 else { return nil } // species or subspecies

            let commonName = taxon["preferred_common_name"] as? String ?? scientificName
            let score = result["score"] as? Double ?? 0

            var photoURL: String? = nil
            if let defaultPhoto = taxon["default_photo"] as? [String: Any] {
                photoURL = defaultPhoto["medium_url"] as? String
                    ?? defaultPhoto["square_url"] as? String
            }

            return IdentificationResult(
                scientificName: scientificName,
                commonName: commonName,
                score: score,
                taxonId: taxonId,
                photoURL: photoURL
            )
        }

        guard !identifications.isEmpty else {
            throw IdentificationError.noResults
        }

        return identifications.sorted { $0.score > $1.score }
    }
}

// MARK: - Data Extensions for Multipart

private extension Data {
    mutating func appendMultipart(boundary: String, name: String, filename: String, mimeType: String, data: Data) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        append(data)
        append("\r\n".data(using: .utf8)!)
    }

    mutating func appendMultipartField(boundary: String, name: String, value: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }
}
