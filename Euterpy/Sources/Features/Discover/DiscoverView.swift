import SwiftUI

/// Session 1 Discover placeholder. Real Discover (charts, country
/// rotation, latest stories, curators) lands in Session 5.
public struct DiscoverView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: EuterpySpacing.xl) {
                    MagazineHeader(
                        eyebrow: "Explore",
                        headline: "Discover what",
                        accent: "moves you.",
                        blurb: "The discovery surface lands in Session 5 — Apple Music charts, country-of-the-day, latest stories, and the curators page."
                    )
                    .padding(.top, EuterpySpacing.xl)
                }
                .padding(.horizontal, EuterpySpacing.xl)
            }
            .background(EuterpyColor.background)
        }
    }
}
