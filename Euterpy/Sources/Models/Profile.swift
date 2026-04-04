import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let username: String
    var displayName: String?
    var bio: String?
    var avatarUrl: String?
    let albumCount: Int
    let followerCount: Int
    let followingCount: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, username, bio
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case albumCount = "album_count"
        case followerCount = "follower_count"
        case followingCount = "following_count"
        case createdAt = "created_at"
    }
}

struct Rating: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let albumId: UUID
    let score: Double
    let reaction: String?
    let createdAt: String

    // Joined data
    var albums: Album?
    var profiles: Profile?

    enum CodingKeys: String, CodingKey {
        case id, score, reaction, albums, profiles
        case userId = "user_id"
        case albumId = "album_id"
        case createdAt = "created_at"
    }
}

struct SongRating: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let songId: UUID
    let score: Double
    let reaction: String?
    let createdAt: String

    var songs: Song?

    enum CodingKeys: String, CodingKey {
        case id, score, reaction, songs
        case userId = "user_id"
        case songId = "song_id"
        case createdAt = "created_at"
    }
}

struct FeedItem: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let actorId: UUID
    let createdAt: String

    var actor: Profile?
    var rating: Rating?

    enum CodingKeys: String, CodingKey {
        case id, actor, rating
        case userId = "user_id"
        case actorId = "actor_id"
        case createdAt = "created_at"
    }
}

struct GetToKnowMeItem: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let position: Int
    let albumId: UUID
    let story: String?

    var albums: Album?

    enum CodingKeys: String, CodingKey {
        case id, position, story, albums
        case userId = "user_id"
        case albumId = "album_id"
    }
}
