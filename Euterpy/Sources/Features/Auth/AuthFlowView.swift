import SwiftUI

/// The auth flow — two screens, replacing v1's seven-step wizard.
///
/// Screen 1: Welcome / sign-in.
///   The brand, a one-line editorial blurb, email + password,
///   "Log in" CTA, and a link to "Make a page" for new users.
///
/// Screen 2: Sign-up.
///   Email + password + username on one screen. Display name and
///   bio are added later in /welcome (the GTKM picking flow that
///   already exists in the codebase) instead of cluttering the
///   initial signup. The principle: get the user *in* first, then
///   help them author their identity.
///
/// We use a single AuthFlowView with an internal mode toggle so
/// switching between log-in and sign-up doesn't require a navigation
/// push. iOS users expect a smooth slide between modes, not a
/// brand-new screen.
public struct AuthFlowView: View {
    enum Mode {
        case signIn
        case signUp
    }

    @Environment(AuthService.self) private var authService

    @State private var mode: Mode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var error: String?
    @State private var loading = false

    public init() {}

    public var body: some View {
        ZStack {
            EuterpyColor.background.ignoresSafeArea()

            // Soft accent glow at the top — same flourish as the
            // web's auth pages and the Session 0 placeholder.
            RadialGradient(
                colors: [EuterpyColor.accent.opacity(0.16), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 360
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            ScrollView {
                VStack(alignment: .leading, spacing: EuterpySpacing.xl) {
                    // Brand
                    Text("Euterpy")
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .foregroundStyle(EuterpyColor.foreground)
                        .padding(.top, EuterpySpacing.lg)

                    // Editorial hero
                    MagazineHeader(
                        eyebrow: mode == .signIn ? "Welcome back" : "Make a page",
                        headline: mode == .signIn ? "The room is" : "A music identity,",
                        accent: mode == .signIn ? "still here." : "handmade.",
                        blurb: mode == .signIn
                            ? "Your three are still on the wall, your stories still on the table. Sign in."
                            : "Three records that explain you. Stories about songs that mattered. Lyrics you carry like tattoos."
                    )

                    // Form card
                    VStack(alignment: .leading, spacing: EuterpySpacing.md) {
                        Eyebrow(mode == .signIn ? "Log in" : "Sign up", tone: .muted)
                            .padding(.bottom, EuterpySpacing.xs)

                        // iOS-specific modifiers (.keyboardType,
                        // .textContentType, .textInputAutocapitalization)
                        // are wrapped in #if os(iOS) so the package
                        // also builds cleanly on macOS for CLI
                        // sanity checks. Real users only ever see
                        // the iOS branch.
                        TextField("Email", text: $email)
                            .modifier(EuterpyTextFieldStyle())
                            .modifier(EmailFieldModifiers(isSignIn: mode == .signIn))

                        SecureField("Password", text: $password)
                            .modifier(EuterpyTextFieldStyle())
                            .modifier(PasswordFieldModifiers(isSignIn: mode == .signIn))

                        if mode == .signUp {
                            TextField("Username", text: Binding(
                                get: { username },
                                set: { username = $0.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "_" } }
                            ))
                            .modifier(EuterpyTextFieldStyle())
                            .modifier(UsernameFieldModifiers())
                        }

                        if let error {
                            Text(error)
                                .font(EuterpyTypography.caption)
                                .foregroundStyle(.red.opacity(0.85))
                                .italic()
                        }

                        EditorialButton(
                            mode == .signIn ? "Log in" : "Create account",
                            isLoading: loading
                        ) {
                            Task { await submit() }
                        }
                        .padding(.top, EuterpySpacing.xs)

                        // Mode toggle
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                error = nil
                                mode = mode == .signIn ? .signUp : .signIn
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text(mode == .signIn ? "New here?" : "Already have an account?")
                                    .foregroundStyle(EuterpyColor.mutedDeep)
                                Text(mode == .signIn ? "Make a page" : "Log in")
                                    .foregroundStyle(EuterpyColor.accent)
                            }
                            .font(EuterpyTypography.caption)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, EuterpySpacing.sm)
                    }
                    .padding(EuterpySpacing.xl)
                    .background(EuterpyColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: EuterpyRadius.xl)
                            .strokeBorder(EuterpyColor.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: EuterpyRadius.xl))

                    Spacer(minLength: EuterpySpacing.xl)
                }
                .padding(.horizontal, EuterpySpacing.xl)
            }
        }
    }

    @MainActor
    private func submit() async {
        error = nil

        // Validation
        guard email.contains("@") else {
            error = "Enter a valid email."
            return
        }
        guard password.count >= 6 else {
            error = "Password needs at least 6 characters."
            return
        }
        if mode == .signUp {
            guard username.count >= 3 else {
                error = "Username needs at least 3 characters."
                return
            }
        }

        loading = true
        defer { loading = false }

        do {
            switch mode {
            case .signIn:
                try await authService.signIn(email: email, password: password)
            case .signUp:
                try await authService.signUp(email: email, password: password, username: username)
            }
            // Auth state listener handles the rest — RootView will
            // re-render and route to MainTabBar.
        } catch {
            self.error = error.localizedDescription
        }
    }
}

/// Reusable text field styling. Matches the web's input pattern:
/// dark card background, hairline border, accent border on focus.
struct EuterpyTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .font(.system(size: 15))
            .foregroundStyle(EuterpyColor.foreground)
            .background(EuterpyColor.background)
            .overlay(
                RoundedRectangle(cornerRadius: EuterpyRadius.md)
                    .strokeBorder(EuterpyColor.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: EuterpyRadius.md))
    }
}

/// iOS-only text input behavior for the email field. Wrapped in
/// #if os(iOS) so the package also builds on macOS for CLI sanity
/// checks — these modifiers don't exist on macOS but the real
/// product only ever runs on iOS.
struct EmailFieldModifiers: ViewModifier {
    let isSignIn: Bool
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .keyboardType(.emailAddress)
            .textContentType(isSignIn ? .username : .emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        #else
        content
        #endif
    }
}

struct PasswordFieldModifiers: ViewModifier {
    let isSignIn: Bool
    func body(content: Content) -> some View {
        #if os(iOS)
        content.textContentType(isSignIn ? .password : .newPassword)
        #else
        content
        #endif
    }
}

struct UsernameFieldModifiers: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .textContentType(.username)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        #else
        content
        #endif
    }
}
