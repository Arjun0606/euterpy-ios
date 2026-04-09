import SwiftUI

/// The four-tab native tab bar that holds the whole app once a user
/// is signed in. Replaces v1's three-tab system bar with system
/// emoji icons.
///
/// Tabs:
///   1. Home — feed, on-this-day, first friday, daily hero
///   2. Discover — charts, country rotation, latest stories, curators
///   3. Profile — your own page (avatar / GTKM / collection / etc)
///   4. Settings — manage account, log out
///
/// Each tab gets its own NavigationStack tied to a NavigationPath
/// owned by the AppCoordinator, so deep links and push notifications
/// can push routes onto the right stack from anywhere in the app.
///
/// Visual: tinted accent magenta, dark color scheme, custom SF
/// Symbol icons (no emoji) so the look matches the rest of the
/// product.
public struct MainTabBar: View {
    @Environment(AppCoordinator.self) private var coordinator

    public init() {}

    public var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.selectedTab) {
            NavigationStack(path: $coordinator.homePath) {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(AppCoordinator.Tab.home)

            NavigationStack(path: $coordinator.discoverPath) {
                DiscoverView()
            }
            .tabItem {
                Label("Discover", systemImage: "sparkles")
            }
            .tag(AppCoordinator.Tab.discover)

            NavigationStack(path: $coordinator.profilePath) {
                ProfileView()
            }
            .tabItem {
                Label("You", systemImage: "person.crop.circle")
            }
            .tag(AppCoordinator.Tab.profile)

            NavigationStack(path: $coordinator.settingsPath) {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(AppCoordinator.Tab.settings)
        }
        .tint(EuterpyColor.accent)
    }
}
