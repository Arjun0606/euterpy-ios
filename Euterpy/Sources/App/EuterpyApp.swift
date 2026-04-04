import SwiftUI

@main
struct EuterpyApp: App {
    @State private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    MainTabView()
                } else {
                    AuthView()
                }
            }
            .environment(authService)
            .preferredColorScheme(.dark)
        }
    }
}
