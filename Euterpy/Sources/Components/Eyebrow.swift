import SwiftUI

/// The `— ALL CAPS` accent text used at the top of every section.
/// Matches the web's `text-[11px] uppercase tracking-[0.22em]
/// text-accent font-semibold` pattern. We use it everywhere; making
/// it a real component means changing the whole product is one edit.
///
/// Three colors are supported via the `tone` parameter — default
/// (accent magenta), muted (zinc), and red (destructive sections).
public struct Eyebrow: View {
    public enum Tone {
        case accent
        case muted
        case red
    }

    let text: String
    let tone: Tone

    public init(_ text: String, tone: Tone = .accent) {
        self.text = text
        self.tone = tone
    }

    public var body: some View {
        Text("— \(text)")
            .font(EuterpyTypography.eyebrow)
            .foregroundStyle(color)
            .textCase(.uppercase)
            .tracking(2.2)
    }

    private var color: Color {
        switch tone {
        case .accent: return EuterpyColor.accent
        case .muted: return EuterpyColor.mutedDeep
        case .red: return Color(red: 0.95, green: 0.4, blue: 0.4)
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 24) {
        Eyebrow("A new beginning")
        Eyebrow("Manage", tone: .muted)
        Eyebrow("Permanent action", tone: .red)
    }
    .padding()
    .background(EuterpyColor.background)
    .preferredColorScheme(.dark)
}
