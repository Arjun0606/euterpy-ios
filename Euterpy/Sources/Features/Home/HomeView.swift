import SwiftUI

/// Session 1 Home placeholder. Real home feed (greeting, On This Day,
/// First Friday banner, friend feed, daily hero) lands in Session 2-4.
public struct HomeView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: EuterpySpacing.xl) {
                    MagazineHeader(
                        eyebrow: "Good morning",
                        headline: "Hello,",
                        accent: "music maven.",
                        blurb: "Your home feed lands in Session 2 — On This Day memories, First Friday, story-of-the-week, and the friend feed."
                    )
                    .padding(.top, EuterpySpacing.xl)

                    ComingSoonCard(
                        eyebrow: "Session 2",
                        title: "Identity primitives.",
                        copy: "Stories, Lyric Pins, Lists, Charts. The composers and the dedicated pages."
                    )

                    ComingSoonCard(
                        eyebrow: "Session 3",
                        title: "The social layer.",
                        copy: "Mark, Echo, Letters, Follow. Followers / Following / Mutuals pages."
                    )

                    ComingSoonCard(
                        eyebrow: "Session 4",
                        title: "Notifications + retention.",
                        copy: "On This Day, First Friday, push notifications routed through deep links."
                    )
                }
                .padding(.horizontal, EuterpySpacing.xl)
                .padding(.bottom, EuterpySpacing.xxxl)
            }
            .background(EuterpyColor.background)
        }
    }
}

private struct ComingSoonCard: View {
    let eyebrow: String
    let title: String
    let copy: String

    var body: some View {
        VStack(alignment: .leading, spacing: EuterpySpacing.sm) {
            Eyebrow(eyebrow, tone: .muted)
            Text(title)
                .font(EuterpyTypography.editorialTitle)
                .foregroundStyle(EuterpyColor.foreground)
            Text(copy)
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
}
