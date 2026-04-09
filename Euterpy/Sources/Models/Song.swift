import Foundation

/// A song in the Euterpy catalog. Mirrors `public.songs`.
public struct Song: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let appleId: String
    public let title: String
    public let artistName: String
    public let artistAppleId: String?
    public let albumName: String?
    public let albumAppleId: String?
    public let durationMs: Int?
    public let artworkUrl: String?
    public let trackNumber: Int?
    public let genreNames: [String]
    public let composerName: String?

    public init(
        id: String,
        appleId: String,
        title: String,
        artistName: String,
        artistAppleId: String? = nil,
        albumName: String? = nil,
        albumAppleId: String? = nil,
        durationMs: Int? = nil,
        artworkUrl: String? = nil,
        trackNumber: Int? = nil,
        genreNames: [String] = [],
        composerName: String? = nil
    ) {
        self.id = id
        self.appleId = appleId
        self.title = title
        self.artistName = artistName
        self.artistAppleId = artistAppleId
        self.albumName = albumName
        self.albumAppleId = albumAppleId
        self.durationMs = durationMs
        self.artworkUrl = artworkUrl
        self.trackNumber = trackNumber
        self.genreNames = genreNames
        self.composerName = composerName
    }
}
