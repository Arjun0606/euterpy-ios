import Foundation

/// A LyricPin — a quoted line from a song that the user "carries
/// like a tattoo." Mirrors `public.lyric_pins`.
///
/// Lyric pins are the most evocative, most shareable primitive on
/// the platform. The share card built around a single pin is one
/// of the highest-leverage artifacts the product produces.
public struct LyricPin: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let userId: String
    public let lyric: String
    public let songAppleId: String
    public let songTitle: String
    public let songArtist: String
    public let songArtworkUrl: String?
    public let position: Int?
    public let createdAt: Date

    public init(
        id: String,
        userId: String,
        lyric: String,
        songAppleId: String,
        songTitle: String,
        songArtist: String,
        songArtworkUrl: String? = nil,
        position: Int? = nil,
        createdAt: Date
    ) {
        self.id = id
        self.userId = userId
        self.lyric = lyric
        self.songAppleId = songAppleId
        self.songTitle = songTitle
        self.songArtist = songArtist
        self.songArtworkUrl = songArtworkUrl
        self.position = position
        self.createdAt = createdAt
    }
}
