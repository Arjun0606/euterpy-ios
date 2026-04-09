import SwiftUI

/// Session 1 Profile placeholder — shows the current user's avatar,
/// name, and bio with the new components in place. Real profile
/// (GTKM carousel, tabs, collection, stories, lyric pins, lists) is
/// rebuilt across Sessions 2 and 3.
public struct ProfileView: View {
    @Environment(AuthService.self) private var authService

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: EuterpySpacing.xl) {
                    if let profile = authService.currentProfile {
                        // Header — avatar + name + handle + bio
                        VStack(alignment: .leading, spacing: EuterpySpacing.md) {
                            Avatar(url: profile.avatarUrl, username: profile.username, size: .xl)

                            Text(profile.resolvedName)
                                .font(EuterpyTypography.editorialHero)
                                .foregroundStyle(EuterpyColor.foreground)
                                .tracking(-1.6)

                            Text("@\(profile.username)")
                                .font(EuterpyTypography.bodyMedium)
                                .foregroundStyle(EuterpyColor.accent)

                            if let bio = profile.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(EuterpyTypography.bodyLarge)
                                    .foregroundStyle(EuterpyColor.muted)
                                    .italic()
                                    .lineSpacing(3)
                                    .padding(.top, EuterpySpacing.xs)
                            }
                        }
                        .padding(.top, EuterpySpacing.xl)
                    } else {
                        Text("Loading…")
                            .font(EuterpyTypography.caption)
                            .foregroundStyle(EuterpyColor.mutedDeep)
                            .padding(.top, EuterpySpacing.xxl)
                    }

                    // Coming-soon notice
                    VStack(alignment: .leading, spacing: EuterpySpacing.sm) {
                        Eyebrow("Coming in Sessions 2 + 3", tone: .muted)
                        Text("Your three, your stories, your lyrics, your collection.")
                            .font(EuterpyTypography.editorialTitle)
                            .foregroundStyle(EuterpyColor.foreground)
                        Text("The full profile rebuild — GTKM carousel, story / lyric / list composers, collection grid, the magazine masthead — lands across the next two sessions.")
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
                }
                .padding(.horizontal, EuterpySpacing.xl)
                .padding(.bottom, EuterpySpacing.xxxl)
            }
            .background(EuterpyColor.background)
        }
    }
}
