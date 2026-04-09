import Foundation

/// A Euterpy profile — what every user looks like to the world.
///
/// Mirrors the `public.profiles` table in Supabase. The Codable
/// conformance uses snake_case keys via PostgrestKeyDecodingStrategy
/// applied at the SupabaseService level (so we don't have to repeat
/// CodingKeys in every model).
///
/// We deliberately don't ship `social_links` or `shelf_style` here
/// even though those columns exist in the database — they're dead on
/// the web (killed in the same session as this iOS rebuild) and we
/// don't want to surface them in iOS just because the column happens
/// to exist. If we ever bring them back, add them to this struct.
public struct Profile: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let username: String
    public let displayName: String?
    public let bio: String?
    public let avatarUrl: String?
    public let albumCount: Int
    public let followerCount: Int
    public let followingCount: Int
    public let isPrivate: Bool
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        username: String,
        displayName: String? = nil,
        bio: String? = nil,
        avatarUrl: String? = nil,
        albumCount: Int = 0,
        followerCount: Int = 0,
        followingCount: Int = 0,
        isPrivate: Bool = false,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.avatarUrl = avatarUrl
        self.albumCount = albumCount
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.isPrivate = isPrivate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// The name to display in the UI — display name if set, otherwise the username.
    public var resolvedName: String {
        displayName?.isEmpty == false ? displayName! : username
    }
}
