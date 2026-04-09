import CoreGraphics

/// Spacing tokens. Same scale as the web's Tailwind config so that
/// when I look at a web component using `mb-8` I know to use
/// `EuterpySpacing.lg` on iOS — they're the same value (32pt = 2rem).
///
/// Why this matters: the v1 codebase had hardcoded paddings
/// everywhere (`.padding(20)`, `.padding(.top, 14)`) and the result
/// was that no two screens felt like they belonged to the same
/// product. Naming spacing values forces consistency and makes the
/// system tunable from one place.
enum EuterpySpacing {
    /// 4pt — the smallest gap, between an icon and its label
    static let xxs: CGFloat = 4
    /// 8pt — chip padding, gap between Mark/Echo buttons
    static let xs: CGFloat = 8
    /// 12pt — card internal padding, between two related items
    static let sm: CGFloat = 12
    /// 16pt — default content padding inside a card
    static let md: CGFloat = 16
    /// 24pt — between cards in a list
    static let lg: CGFloat = 24
    /// 32pt — between sections on a page
    static let xl: CGFloat = 32
    /// 48pt — page header → first section
    static let xxl: CGFloat = 48
    /// 64pt — major page sections, hero spacing
    static let xxxl: CGFloat = 64
}

/// Corner radius tokens. The whole product uses 3 sizes:
/// pill (buttons), card (rectangles), and the big rounded
/// container for hero blocks.
enum EuterpyRadius {
    /// Pill — fully rounded buttons and chips
    static let pill: CGFloat = 999
    /// Small — input fields, inline badges
    static let sm: CGFloat = 8
    /// Medium — cover thumbnails, list rows
    static let md: CGFloat = 12
    /// Large — the standard card
    static let lg: CGFloat = 16
    /// Extra large — the magazine-grade hero containers
    static let xl: CGFloat = 24
    /// 2xl — the biggest containers, full-bleed editorial blocks
    static let xxl: CGFloat = 32
}
