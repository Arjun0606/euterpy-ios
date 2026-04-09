import SwiftUI

/// The Euterpy typography scale. This is the foundation that makes
/// every screen feel like it belongs to the same magazine. Every
/// view in the app should reach for one of these named styles
/// instead of hardcoding `.font(.system(size: 28, weight: ...))` —
/// that's exactly the path that produced the inconsistent v1.
///
/// Two type families are loaded:
///   1. **Fraunces** — the editorial display serif. Used for
///      headlines, the eyebrows, the magazine identity. Loaded as
///      a real font asset in Resources/Fonts/. The web app uses
///      Fraunces for the same reason — it's the visual signature.
///      Until we ship the .ttf assets in Session 1, this falls back
///      to system serif so the app still compiles + reads as
///      editorial-adjacent.
///   2. **System sans (SF Pro / Inter)** — for body, captions,
///      buttons. The web uses Inter; iOS users get the OS default
///      because that's what feels native and SF Pro is excellent.
///
/// The naming is deliberate: every style says what it's *for*, not
/// what it *is*. `.editorialHero` instead of `.serif64`. This means
/// when we want to make the hero bigger, we change one constant
/// here and every hero gets larger together.
enum EuterpyTypography {
    // MARK: - Display serif (Fraunces)

    /// The biggest type in the app. Used for the home greeting,
    /// the dedicated page headers ("People who've made something
    /// here"), the Annual cover. Roughly matches web `font-display
    /// text-5xl sm:text-7xl`.
    static let editorialHero = Font.custom(
        "Fraunces",
        size: 56,
        relativeTo: .largeTitle
    )

    /// One step down — section headers, story headlines, list
    /// titles on the dedicated list page. Matches web
    /// `font-display text-4xl`.
    static let editorialDisplay = Font.custom(
        "Fraunces",
        size: 38,
        relativeTo: .title
    )

    /// Card titles, profile display name. Matches web
    /// `font-display text-2xl`.
    static let editorialTitle = Font.custom(
        "Fraunces",
        size: 24,
        relativeTo: .title2
    )

    /// Inline display — used for "Track 4 · 3:46 · R&B" style
    /// metadata that wants to be slightly more editorial than body.
    static let editorialSubtitle = Font.custom(
        "Fraunces",
        size: 18,
        relativeTo: .headline
    )

    // MARK: - Body sans (system)

    /// Default body copy. Reading text. Bio paragraphs.
    static let body = Font.system(size: 15, weight: .regular, design: .default)

    /// Slightly larger body — used for editorial blurbs that lead
    /// a section but aren't the headline.
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)

    /// Medium emphasis — usernames, primary metadata.
    static let bodyMedium = Font.system(size: 14, weight: .medium, design: .default)

    /// Captions — dates, "X marks ago", small metadata.
    static let caption = Font.system(size: 12, weight: .regular, design: .default)

    /// The eyebrow style — uppercase tracked accent text used at
    /// the top of every section. e.g. "— A EUTERPY HOLIDAY".
    /// Always paired with `Color = .accent` and `tracking = 0.22em`
    /// (or its equivalent in points).
    static let eyebrow = Font.system(size: 11, weight: .semibold, design: .default)

    /// The smallest legible type. Tag chips, footer micro-copy.
    static let micro = Font.system(size: 10, weight: .semibold, design: .default)
}

/// Helper extension to apply the eyebrow look in one chained call.
/// Eyebrows are used everywhere in the app, so this saves repeated
/// `.font().foregroundColor().textCase().tracking()` chains.
extension Text {
    func eyebrowStyle(color: Color = EuterpyColor.accent) -> some View {
        self
            .font(EuterpyTypography.eyebrow)
            .foregroundStyle(color)
            .textCase(.uppercase)
            .tracking(2.2)
    }
}
