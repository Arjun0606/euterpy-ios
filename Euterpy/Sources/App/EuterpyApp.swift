import SwiftUI

/// Euterpy iOS — entry point.
///
/// This is Session 0 of the rebuild. The v1 codebase is preserved
/// on the `archive/v1` branch and is no longer the source of truth.
/// Everything from this point forward is built on the design system
/// in `Theme/`, the routing layer in `Routing/` (coming Session 1),
/// and the repository / service architecture in `Repositories/` and
/// `Services/` (coming Session 1).
///
/// The visible behavior in Session 0 is intentionally minimal: a
/// single magazine-styled welcome screen that proves the foundation
/// builds and runs. The point of Session 0 is to ship the
/// scaffolding, not the features. Features start in Session 1.
@main
struct EuterpyApp: App {
    var body: some Scene {
        WindowGroup {
            FoundationWelcomeScreen()
                .preferredColorScheme(.dark)
        }
    }
}

/// The Session 0 placeholder. Replaced in Session 1 by the real
/// auth flow + main tab structure. Exists so the project compiles,
/// runs, and gives a visual proof that the design system is wired.
private struct FoundationWelcomeScreen: View {
    var body: some View {
        ZStack {
            EuterpyColor.background
                .ignoresSafeArea()

            // Soft accent glow at the top — the same gradient flourish
            // the web uses on hero sections. Subtle but signature.
            RadialGradient(
                colors: [
                    EuterpyColor.accent.opacity(0.18),
                    .clear,
                ],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: EuterpySpacing.lg) {
                Text("— A new beginning")
                    .eyebrowStyle()

                Text("Euterpy.")
                    .font(EuterpyTypography.editorialHero)
                    .foregroundStyle(EuterpyColor.foreground)
                    .tracking(-1.8)

                Text("A music identity. Being rebuilt — properly this time.")
                    .font(EuterpyTypography.bodyLarge)
                    .foregroundStyle(EuterpyColor.muted)
                    .italic()

                Spacer()

                VStack(alignment: .leading, spacing: EuterpySpacing.xs) {
                    Text("Session 0 · The foundation")
                        .font(EuterpyTypography.eyebrow)
                        .foregroundStyle(EuterpyColor.mutedDeep)
                        .textCase(.uppercase)
                        .tracking(1.8)

                    Text("Theme system, design tokens, scaffolding. Features start in Session 1.")
                        .font(EuterpyTypography.caption)
                        .foregroundStyle(EuterpyColor.mutedDeepest)
                }
            }
            .padding(EuterpySpacing.xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
