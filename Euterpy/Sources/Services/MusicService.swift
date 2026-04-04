import Foundation

/// Calls the Euterpy web API for album/song search and data.
/// This ensures both iOS and web use the same data pipeline.
class MusicService {
    static let shared = MusicService()

    // TODO: Update to production URL
    private let baseURL = "https://euterpy.app"

    struct AlbumSearchResult: Codable, Identifiable {
        let appleId: String
        let title: String
        let artistName: String
        let releaseDate: String?
        let artworkUrl: String?

        var id: String { appleId }

        func artworkURL(size: Int = 500) -> URL? {
            guard let template = artworkUrl else { return nil }
            let resolved = template
                .replacingOccurrences(of: "{w}", with: "\(size)")
                .replacingOccurrences(of: "{h}", with: "\(size)")
            return URL(string: resolved)
        }
    }

    struct SongSearchResult: Codable, Identifiable {
        let appleId: String
        let title: String
        let artistName: String
        let albumName: String?
        let artworkUrl: String?
        let durationMs: Int?

        var id: String { appleId }

        var formattedDuration: String {
            guard let ms = durationMs else { return "" }
            let mins = ms / 60000
            let secs = (ms % 60000) / 1000
            return "\(mins):\(String(format: "%02d", secs))"
        }
    }

    func searchAlbums(query: String) async throws -> [AlbumSearchResult] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/api/albums/search?q=\(encoded)")!

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(SearchResponse<AlbumSearchResult>.self, from: data)
        return response.results
    }

    func searchSongs(query: String) async throws -> [SongSearchResult] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/api/songs/search?q=\(encoded)")!

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(SearchResponse<SongSearchResult>.self, from: data)
        return response.results
    }

    private struct SearchResponse<T: Codable>: Codable {
        let results: [T]
    }
}
