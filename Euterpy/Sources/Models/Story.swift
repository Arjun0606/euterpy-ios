import Foundation

/// A Story — long-form writing about a song / album / artist. Mirrors
/// the `public.stories` table.
///
/// Stories are the deepest identity primitive in the product. Every
/// story has a target (the thing being written about), an optional
/// headline, and a body. Letters (replies) live in `public.story_comments`
/// and are loaded separately by StoryRepository when a story page is opened.
public struct Story: Codable, Identifiable, Hashable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case song
        case album
        case artist
    }

    public let id: String
    public let userId: String
    public let kind: Kind
    public let targetAppleId: String
    public let targetTitle: String
    public let targetArtist: String?
    public let targetArtworkUrl: String?
    public let headline: String?
    public let body: String
    public let isPinned: Bool
    public let createdAt: Date
    public let updatedAt: Date?

    public init(
        id: String,
        userId: String,
        kind: Kind,
        targetAppleId: String,
        targetTitle: String,
        targetArtist: String? = nil,
        targetArtworkUrl: String? = nil,
        headline: String? = nil,
        body: String,
        isPinned: Bool = false,
        createdAt: Date,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.kind = kind
        self.targetAppleId = targetAppleId
        self.targetTitle = targetTitle
        self.targetArtist = targetArtist
        self.targetArtworkUrl = targetArtworkUrl
        self.headline = headline
        self.body = body
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
