import Foundation

/// HTTP client for the Euterpy web API. The other half of the hybrid
/// architecture documented in ARCHITECTURE.md — iOS calls into
/// `euterpy.com/api/*` for anything that's computed, literary, or
/// editorial (notification copy, curator status, On This Day, First
/// Friday state, the Annual editorial composer, Apple Music catalog
/// search). Both web and iOS share the same TypeScript implementation
/// of those rules. Drift is impossible by construction.
///
/// Catalog search is the most-called endpoint and the one that
/// already exists end-to-end on the web, so it's the first method
/// added here. The literary endpoints get their own methods as we
/// build the features that need them in later sessions.
public final class WebAPIService {
    public static let shared = WebAPIService()

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    /// Errors that surface from the web API. Kept simple — most
    /// callers want to either show "couldn't load" or fall back to
    /// a cached/empty value.
    public enum APIError: Error, LocalizedError {
        case invalidResponse
        case httpStatus(Int)
        case decodingFailure(Error)

        public var errorDescription: String? {
            switch self {
            case .invalidResponse: return "Invalid response from Euterpy."
            case .httpStatus(let code): return "Euterpy returned HTTP \(code)."
            case .decodingFailure(let err): return "Couldn't decode response: \(err.localizedDescription)"
            }
        }
    }

    /// GET helper. Builds a URL by joining a path against the
    /// configured `webBaseURL`, decodes JSON into the requested type.
    private func get<T: Decodable>(_ path: String, as type: T.Type) async throws -> T {
        var url = EuterpyConfig.webBaseURL
        url.append(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Euterpy-iOS/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailure(error)
        }
    }
}
