import Foundation

/// A curated list of songs and/or albums. Mirrors `public.lists`.
///
/// Named MusicList instead of List to avoid colliding with SwiftUI.List —
/// SwiftUI's identifier wins in scope, and we don't want every view that
/// imports a Euterpy list type to have to disambiguate.
public struct MusicList: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let userId: String
    public let title: String
    public let subtitle: String?
    public let createdAt: Date
    public let updatedAt: Date?
    public let items: [MusicListItem]?

    public init(
        id: String,
        userId: String,
        title: String,
        subtitle: String? = nil,
        createdAt: Date,
        updatedAt: Date? = nil,
        items: [MusicListItem]? = nil
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.subtitle = subtitle
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.items = items
    }
}

public struct MusicListItem: Codable, Identifiable, Hashable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case song
        case album
    }

    public let id: String
    public let listId: String
    public let position: Int
    public let kind: Kind
    public let targetAppleId: String
    public let targetTitle: String
    public let targetArtist: String?
    public let targetArtworkUrl: String?
    public let caption: String?

    public init(
        id: String,
        listId: String,
        position: Int,
        kind: Kind,
        targetAppleId: String,
        targetTitle: String,
        targetArtist: String? = nil,
        targetArtworkUrl: String? = nil,
        caption: String? = nil
    ) {
        self.id = id
        self.listId = listId
        self.position = position
        self.kind = kind
        self.targetAppleId = targetAppleId
        self.targetTitle = targetTitle
        self.targetArtist = targetArtist
        self.targetArtworkUrl = targetArtworkUrl
        self.caption = caption
    }
}
