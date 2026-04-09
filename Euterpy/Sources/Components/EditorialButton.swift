import SwiftUI

/// The button primitive used everywhere in the app. Three styles —
/// filled (the primary CTA, accent magenta), outlined (the
/// neutral secondary), and ghost (the quietest, used inline as a
/// link-style action).
///
/// Pulled into a reusable component because v1 had every screen
/// hardcoding its own `.background(EuterpyColor.accent)` blocks.
/// Centralizing here means tuning button rounding / padding / hover
/// behavior is one edit, not twenty.
public struct EditorialButton: View {
    public enum Style {
        case filled
        case outlined
        case ghost
        case destructive
    }

    let title: String
    let style: Style
    let isLoading: Bool
    let action: () -> Void

    public init(
        _ title: String,
        style: Style = .filled,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foregroundColor)
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
        }
        .disabled(isLoading)
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isLoading)
    }

    private var backgroundColor: Color {
        switch style {
        case .filled: return EuterpyColor.accent
        case .outlined: return .clear
        case .ghost: return .clear
        case .destructive: return Color(red: 0.85, green: 0.2, blue: 0.2)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .filled, .destructive: return .white
        case .outlined: return EuterpyColor.foreground
        case .ghost: return EuterpyColor.muted
        }
    }

    private var borderColor: Color {
        switch style {
        case .filled, .destructive: return .clear
        case .outlined: return EuterpyColor.border
        case .ghost: return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .filled, .destructive, .ghost: return 0
        case .outlined: return 1
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        EditorialButton("Visit your three →") { }
        EditorialButton("Log in", style: .outlined) { }
        EditorialButton("Skip for now", style: .ghost) { }
        EditorialButton("Delete forever", style: .destructive) { }
        EditorialButton("Saving...", isLoading: true) { }
    }
    .padding()
    .background(EuterpyColor.background)
    .preferredColorScheme(.dark)
}
