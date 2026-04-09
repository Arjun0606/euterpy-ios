import Foundation

/// An album in the Euterpy catalog. Mirrors `public.albums` in Supabase.
/// Catalog data originates from Apple Music — Euterpy stores a mirror
/// row the first time anyone interacts with an album so we can attach
/// our own data (ratings, stories, lyric pins) to a stable id.
public struct Album: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let appleId: String
    public let title: String
    public let artistName: String
    public let artistAppleId: String?
    public let artworkUrl: String?
    public let releaseDate: String?
    public let genreNames: [String]
    public let trackCount: Int?
    public let recordLabel: String?
    public let albumType: String?     // "album" | "ep" | "single" | "compilation"
    public let ratingCount: Int
    public let averageRating: Double?

    public init(
        id: String,
        appleId: String,
        title: String,
        artistName: String,
        artistAppleId: String? = nil,
        artworkUrl: String? = nil,
        releaseDate: String? = nil,
        genreNames: [String] = [],
        trackCount: Int? = nil,
        recordLabel: String? = nil,
        albumType: String? = nil,
        ratingCount: Int = 0,
        averageRating: Double? = nil
    ) {
        self.id = id
        self.appleId = appleId
        self.title = title
        self.artistName = artistName
        self.artistAppleId = artistAppleId
        self.artworkUrl = artworkUrl
        self.releaseDate = releaseDate
        self.genreNames = genreNames
        self.trackCount = trackCount
        self.recordLabel = recordLabel
        self.albumType = albumType
        self.ratingCount = ratingCount
        self.averageRating = averageRating
    }
}
