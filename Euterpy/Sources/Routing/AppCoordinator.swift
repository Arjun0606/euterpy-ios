import SwiftUI
import Observation

/// The navigation coordinator. Owns one NavigationPath per main tab,
/// exposes a single `navigate(to:)` API that any view can call to
/// push a Route onto the current tab's stack.
///
/// This is the entry point that lets push notifications, deep links,
/// and inline links all use the same navigation API. They all
/// produce a `Route`, hand it to the coordinator, the coordinator
/// figures out which tab it belongs in and pushes accordingly.
///
/// In Session 1 we wire the coordinator + route enum + the path
/// state. The actual screen mapping (Route → SwiftUI view) lives in
/// `RootView` so each tab can pass its own NavigationPath binding.
@Observable
public final class AppCoordinator {
    public enum Tab: Hashable {
        case home
        case discover
        case profile
        case settings
    }

    public var selectedTab: Tab = .home

    public var homePath = NavigationPath()
    public var discoverPath = NavigationPath()
    public var profilePath = NavigationPath()
    public var settingsPath = NavigationPath()

    public init() {}

    /// Navigate to a route. Routes are routed into the most
    /// semantically appropriate tab; e.g. tapping a notification
    /// for a new follower lands on the Profile tab so the user can
    /// see their own followers list, while tapping an album link
    /// lands in the Discover tab where albums live.
    public func navigate(to route: Route) {
        let tab = preferredTab(for: route)
        selectedTab = tab
        switch tab {
        case .home: homePath.append(route)
        case .discover: discoverPath.append(route)
        case .profile: profilePath.append(route)
        case .settings: settingsPath.append(route)
        }
    }

    /// Pop everything off a tab's stack. Used when a user re-taps
    /// the same tab — standard iOS behavior.
    public func resetTab(_ tab: Tab) {
        switch tab {
        case .home: homePath = NavigationPath()
        case .discover: discoverPath = NavigationPath()
        case .profile: profilePath = NavigationPath()
        case .settings: settingsPath = NavigationPath()
        }
    }

    private func preferredTab(for route: Route) -> Tab {
        switch route {
        case .profile, .profileFollowers, .profileFollowing,
             .profileMutuals, .profileStats, .profileCharts:
            return .profile
        case .album, .song, .artist, .discover, .curators, .people:
            return .discover
        case .story, .lyricPin, .musicList, .firstFriday, .annual:
            return .home
        case .settings, .gtkm, .notifications:
            return .settings
        }
    }
}
