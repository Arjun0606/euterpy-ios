import SwiftUI

/// Euterpy iOS — entry point.
///
/// Session 1 is live: real auth, real components, real navigation
/// scaffolding, four-tab native shell. The placeholder welcome
/// screen from Session 0 has been replaced by the real RootView,
/// which routes between AuthFlowView (signed out) and MainTabBar
/// (signed in) based on the AuthService state.
///
/// Two long-lived services are constructed once at app launch and
/// passed down via the SwiftUI environment so every view can read
/// them with `@Environment(AuthService.self)` and
/// `@Environment(AppCoordinator.self)`:
///
///   - AuthService: the auth state machine. Owns currentUserId,
///     currentProfile, sign-in / sign-up / sign-out, and the
///     long-running listener for token refresh + remote sign-out.
///
///   - AppCoordinator: the navigation router. Holds one
///     NavigationPath per tab and routes Routes into the right one.
///
/// Universal links from `https://euterpy.com/...` are intercepted
/// by `.onOpenURL` on the root scene and parsed into Routes via
/// `DeepLinkHandler`. The coordinator handles the rest.
@main
struct EuterpyApp: App {
    @State private var authService: AuthService
    @State private var coordinator = AppCoordinator()

    init() {
        // Start listening to auth state changes immediately. The
        // listener owns the source of truth for "is the user
        // signed in," so it must be live before any view tries to
        // read `authService.state`.
        let auth = AuthService()
        auth.start()
        _authService = State(initialValue: auth)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authService)
                .environment(coordinator)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    if let route = DeepLinkHandler.route(from: url) {
                        coordinator.navigate(to: route)
                    }
                }
        }
    }
}

/// Routes between the auth flow and the main tab bar based on
/// AuthService state. Single source of truth for "what does the
/// user see right now."
struct RootView: View {
    @Environment(AuthService.self) private var authService

    var body: some View {
        ZStack {
            EuterpyColor.background.ignoresSafeArea()

            switch authService.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(EuterpyColor.accent)
            case .signedIn:
                MainTabBar()
                    .transition(.opacity)
            case .signedOut:
                AuthFlowView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: authService.state)
    }
}
