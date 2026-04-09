import SwiftUI

/// The header pattern that opens every "page" in the product:
///   eyebrow → display headline → italic editorial blurb.
///
/// Used at the top of profile, settings, discover, every dedicated
/// list/story page, etc. Composing it as a single component means
/// the rhythm is consistent across the whole app — same spacing,
/// same proportions, same voice.
///
/// The accent fragment (`accent`) is the part of the headline that
/// renders in italic accent magenta — Euterpy's signature
/// "X is something" sentence shape ("Today is *First Friday*", "The
/// room is *visiting its three*", "Settings.").
public struct MagazineHeader: View {
    let eyebrow: String
    let headline: String
    let accent: String?
    let blurb: String?

    public init(
        eyebrow: String,
        headline: String,
        accent: String? = nil,
        blurb: String? = nil
    ) {
        self.eyebrow = eyebrow
        self.headline = headline
        self.accent = accent
        self.blurb = blurb
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Eyebrow(eyebrow)
                .padding(.bottom, EuterpySpacing.md)

            // Headline + optional accent fragment on the same line.
            // We use Text concatenation with a trailing italic accent
            // span so word wrapping behaves naturally.
            (
                Text(headline)
                    .font(EuterpyTypography.editorialHero)
                    .foregroundStyle(EuterpyColor.foreground)
                +
                (accent.map { fragment in
                    Text(" \(fragment)")
                        .font(EuterpyTypography.editorialHero)
                        .italic()
                        .foregroundStyle(EuterpyColor.accent)
                } ?? Text(""))
            )
            .tracking(-1.6)
            .lineSpacing(-8)

            if let blurb {
                Text(blurb)
                    .font(EuterpyTypography.bodyLarge)
                    .italic()
                    .foregroundStyle(EuterpyColor.muted)
                    .lineSpacing(4)
                    .padding(.top, EuterpySpacing.lg)
                    .frame(maxWidth: 540, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 48) {
            MagazineHeader(
                eyebrow: "Manage",
                headline: "Settings."
            )

            MagazineHeader(
                eyebrow: "A Euterpy holiday",
                headline: "Today, the room is",
                accent: "visiting its three.",
                blurb: "First Friday. The one day a month everyone here looks at their own pages again — keeps what still belongs, swaps what doesn't."
            )
        }
        .padding(EuterpySpacing.xl)
    }
    .background(EuterpyColor.background)
    .preferredColorScheme(.dark)
}
