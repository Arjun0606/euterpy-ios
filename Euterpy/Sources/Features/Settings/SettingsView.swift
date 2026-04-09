import SwiftUI

/// Session 1 Settings — minimal but functional. Real settings
/// (avatar upload, display name, bio, privacy, blocked users,
/// pending requests, delete account) lands in Sessions 4-6.
///
/// What we ship in Session 1: a clean magazine header and a working
/// Log out button so users always have a door out from day one.
public struct SettingsView: View {
    @Environment(AuthService.self) private var authService

    @State private var signingOut = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: EuterpySpacing.xl) {
                    MagazineHeader(
                        eyebrow: "Manage",
                        headline: "Settings."
                    )
                    .padding(.top, EuterpySpacing.xl)

                    // Coming-soon notice
                    VStack(alignment: .leading, spacing: EuterpySpacing.sm) {
                        Eyebrow("Coming in later sessions", tone: .muted)
                        Text("Avatar, display name, bio, privacy.")
                            .font(EuterpyTypography.editorialTitle)
                            .foregroundStyle(EuterpyColor.foreground)
                        Text("All of the editable profile surfaces land as the matching repository methods come online.")
                            .font(EuterpyTypography.body)
                            .foregroundStyle(EuterpyColor.muted)
                            .italic()
                            .lineSpacing(3)
                    }
                    .padding(EuterpySpacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(EuterpyColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: EuterpyRadius.lg)
                            .strokeBorder(EuterpyColor.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: EuterpyRadius.lg))

                    // Account section — log out works from day one.
                    VStack(alignment: .leading, spacing: EuterpySpacing.md) {
                        Eyebrow("Account")

                        Text("The door.")
                            .font(EuterpyTypography.editorialTitle)
                            .foregroundStyle(EuterpyColor.foreground)

                        Text("Logging out signs you out of this device. You can come back any time.")
                            .font(EuterpyTypography.body)
                            .foregroundStyle(EuterpyColor.muted)
                            .italic()
                            .lineSpacing(3)
                            .padding(.bottom, EuterpySpacing.xs)

                        EditorialButton(
                            "Log out",
                            style: .outlined,
                            isLoading: signingOut
                        ) {
                            Task {
                                signingOut = true
                                await authService.signOut()
                                signingOut = false
                            }
                        }
                    }
                    .padding(.top, EuterpySpacing.xl)
                }
                .padding(.horizontal, EuterpySpacing.xl)
                .padding(.bottom, EuterpySpacing.xxxl)
            }
            .background(EuterpyColor.background)
        }
    }
}
