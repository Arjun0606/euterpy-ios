import Foundation

struct Album: Codable, Identifiable, Hashable {
    let id: UUID
    let appleId: String
    let title: String
    let artistName: String
    let releaseDate: String?
    let artworkUrl: String?
    let genreNames: [String]?
    let trackCount: Int?
    let ratingCount: Int
    let averageRating: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case appleId = "apple_id"
        case title
        case artistName = "artist_name"
        case releaseDate = "release_date"
        case artworkUrl = "artwork_url"
        case genreNames = "genre_names"
        case trackCount = "track_count"
        case ratingCount = "rating_count"
        case averageRating = "average_rating"
    }

    /// Resolve Apple Music artwork URL template to a real URL
    func artworkURL(size: Int = 500) -> URL? {
        guard let template = artworkUrl else { return nil }
        let resolved = template
            .replacingOccurrences(of: "{w}", with: "\(size)")
            .replacingOccurrences(of: "{h}", with: "\(size)")
        return URL(string: resolved)
    }
}

struct Song: Codable, Identifiable, Hashable {
    let id: UUID
    let appleId: String
    let title: String
    let artistName: String
    let albumName: String?
    let durationMs: Int?
    let artworkUrl: String?
    let trackNumber: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case appleId = "apple_id"
        case title
        case artistName = "artist_name"
        case albumName = "album_name"
        case durationMs = "duration_ms"
        case artworkUrl = "artwork_url"
        case trackNumber = "track_number"
    }

    func artworkURL(size: Int = 300) -> URL? {
        guard let template = artworkUrl else { return nil }
        let resolved = template
            .replacingOccurrences(of: "{w}", with: "\(size)")
            .replacingOccurrences(of: "{h}", with: "\(size)")
        return URL(string: resolved)
    }

    var formattedDuration: String {
        guard let ms = durationMs else { return "" }
        let mins = ms / 60000
        let secs = (ms % 60000) / 1000
        return "\(mins):\(String(format: "%02d", secs))"
    }
}
