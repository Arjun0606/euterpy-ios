import SwiftUI

/// The Euterpy color palette. Matches the web app's design tokens
/// 1:1 so a screenshot from web and a screenshot from iOS use the
/// exact same hex values for accent, background, card, border, etc.
///
/// Dark mode is forced everywhere. Euterpy is an editorial dark
/// product the way a hand-set magazine is a dark product when you
/// hold it under a reading lamp — the visual identity is the dark
/// background, the magenta accent, the muted zinc grays. We do not
/// support light mode and we will not.
///
/// The hex helper is the cleanest way to make CSS-style hex strings
/// work in SwiftUI without dragging in Foundation's NSColor.
enum EuterpyColor {
    /// The page background — pure black, the same as the web's `bg-background`.
    static let background = Color(hex: "#000000")

    /// Card surface — slightly lifted off black so the rounded
    /// rectangles read as objects, not paint. Matches web `bg-card`.
    static let card = Color(hex: "#0a0a0a")

    /// Card hover state — used on tappable rows in lists.
    static let cardHover = Color(hex: "#111111")

    /// The hairline borders that separate cards from background.
    /// Same as web `border-border`.
    static let border = Color(hex: "#27272a")

    /// Foreground text — the white we use for headlines and primary copy.
    static let foreground = Color(hex: "#fafafa")

    /// Muted text — used for bios, dates, secondary metadata.
    static let muted = Color(hex: "#a1a1aa")

    /// Even quieter — captions, eyebrows, the smallest editorial tags.
    static let mutedDeep = Color(hex: "#71717a")

    /// The deepest gray — borders on borders, vinyl shadows.
    static let mutedDeepest = Color(hex: "#52525b")

    /// The single accent. The Euterpy magenta. Matches `accent` on web.
    /// Used sparingly. The whole identity rests on this one color
    /// being unmistakable when it appears, so we never overuse it.
    static let accent = Color(hex: "#FF1493")

    /// Hover state for the accent — slightly brighter, used on
    /// primary CTA buttons.
    static let accentHover = Color(hex: "#ff3da5")
}

extension Color {
    /// Initialize a `Color` from a CSS-style hex string ("#RRGGBB" or
    /// "RRGGBB"). Lets us match the web's design tokens 1:1 instead
    /// of guessing at sRGB triplets in code.
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b: Double
        switch cleaned.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 0
            g = 0
            b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}
