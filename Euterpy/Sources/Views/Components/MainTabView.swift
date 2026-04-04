import SwiftUI

struct MainTabView: View {
    @Environment(AuthService.self) private var authService

    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "square.stack")
                    Text("Feed")
                }

            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }

            ProfileView(username: authService.currentProfile?.username ?? "")
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .tint(Theme.accent)
    }
}
