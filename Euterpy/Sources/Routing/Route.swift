import Foundation

/// Every navigable destination in the app, modeled as a single enum.
///
/// The reason this exists: in v1, navigation was scattered across
/// individual views with NavigationLinks pointing at hardcoded
/// destinations. There was no way for a push notification or a
/// deep link to navigate anywhere because nothing knew how to
/// translate "this URL" into "this screen."
///
/// Now: any caller (deep link, push notification, share sheet,
/// in-app button) can request `Route.story(id)` and the
/// AppCoordinator pushes the right screen onto the right
/// NavigationStack. The Route enum is the contract.
public enum Route: Hashable, Codable {
    case profile(username: String)
    case profileFollowers(username: String)
    case profileFollowing(username: String)
    case profileMutuals(username: String)
    case profileStats(username: String)
    case profileCharts(username: String)

    case album(appleId: String)
    case song(appleId: String)
    case artist(appleId: String)

    case story(id: String)
    case lyricPin(id: String)
    case musicList(id: String)

    case discover
    case curators
    case people

    case firstFriday
    case annual

    case settings
    case gtkm
    case notifications
}
