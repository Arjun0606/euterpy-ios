import Foundation

/// Parse a Euterpy URL into a Route. The same parser handles:
///   - Universal links from the web (https://euterpy.com/...)
///   - Custom URL scheme links from push notifications
///   - Share sheet "Open in Euterpy" actions
///
/// Anything that can produce a Route should go through this parser
/// so we have one place to update when URL conventions change.
public enum DeepLinkHandler {
    /// Try to convert a URL into a Route. Returns nil if the URL
    /// doesn't match any known pattern.
    public static func route(from url: URL) -> Route? {
        // Strip query params and fragment — those are not routing-relevant.
        let segments = url.pathComponents.filter { $0 != "/" }
        guard !segments.isEmpty else { return nil }

        switch segments[0] {
        case "album" where segments.count >= 2:
            return .album(appleId: segments[1])
        case "song" where segments.count >= 2:
            return .song(appleId: segments[1])
        case "artist" where segments.count >= 2:
            return .artist(appleId: segments[1])
        case "story" where segments.count >= 2:
            return .story(id: segments[1])
        case "list" where segments.count >= 2:
            return .musicList(id: segments[1])
        case "discover":
            return .discover
        case "curators":
            return .curators
        case "people":
            return .people
        case "first-friday":
            return .firstFriday
        case "annual":
            return .annual
        case "settings":
            return .settings
        case "gtkm":
            return .gtkm
        case "notifications":
            return .notifications

        // /[username] and /[username]/<subpath>
        default:
            let username = segments[0]
            if segments.count == 1 {
                return .profile(username: username)
            }
            switch segments[1] {
            case "followers": return .profileFollowers(username: username)
            case "following": return .profileFollowing(username: username)
            case "mutuals": return .profileMutuals(username: username)
            case "stats": return .profileStats(username: username)
            case "charts": return .profileCharts(username: username)
            default: return .profile(username: username)
            }
        }
    }
}
