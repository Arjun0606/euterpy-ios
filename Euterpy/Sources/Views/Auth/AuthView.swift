import SwiftUI

struct AuthView: View {
    @State private var step: AuthStep = .welcome
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var error: String?
    @State private var loading = false
    @Environment(AuthService.self) private var authService

    enum AuthStep {
        case welcome, email, password, username, login
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            switch step {
            case .welcome:
                welcomeView
            case .email:
                emailView
            case .password:
                passwordView
            case .username:
                usernameView
            case .login:
                loginView
            }

            Spacer()
        }
        .background(Theme.background)
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    // MARK: - Welcome
    private var welcomeView: some View {
        VStack(spacing: 8) {
            Text("Hello,")
                .font(.system(size: 48, weight: .regular, design: .serif))
                .foregroundStyle(.white)
            Text("Musical Maven!")
                .font(.system(size: 48, weight: .regular, design: .serif))
                .foregroundStyle(Theme.accent)

            Text("Your music taste deserves a home.")
                .font(.subheadline)
                .foregroundStyle(Theme.muted)
                .padding(.top, 4)
                .padding(.bottom, 40)

            Button {
                step = .email
            } label: {
                Text("Get Started")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)

            Button("Already have an account? Log in") {
                step = .login
            }
            .font(.caption)
            .foregroundStyle(Theme.accent)
            .padding(.top, 20)
        }
    }

    // MARK: - Email
    private var emailView: some View {
        VStack(alignment: .leading, spacing: 16) {
            backButton { step = .welcome }

            Text("What's your email?")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundStyle(.white)
            Text("We'll use this to create your account.")
                .font(.subheadline)
                .foregroundStyle(Theme.muted)

            TextField("you@email.com", text: $email)
                .textFieldStyle(EuterpyTextFieldStyle())
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            mainButton("Continue") {
                if email.contains("@") { step = .password; error = nil }
                else { error = "Enter a valid email" }
            }
            .disabled(!email.contains("@"))

            errorText
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Password
    private var passwordView: some View {
        VStack(alignment: .leading, spacing: 16) {
            backButton { step = .email }

            Text("Set a password")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundStyle(.white)
            Text("At least 6 characters.")
                .font(.subheadline)
                .foregroundStyle(Theme.muted)

            SecureField("Password", text: $password)
                .textFieldStyle(EuterpyTextFieldStyle())

            mainButton("Continue") {
                if password.count >= 6 { step = .username; error = nil }
                else { error = "Password must be at least 6 characters" }
            }
            .disabled(password.count < 6)

            errorText
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Username
    private var usernameView: some View {
        VStack(alignment: .leading, spacing: 16) {
            backButton { step = .password }

            Text("Pick a username")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundStyle(.white)
            Text("This is how people will find you.")
                .font(.subheadline)
                .foregroundStyle(Theme.muted)

            HStack(spacing: 0) {
                Text("@")
                    .foregroundStyle(Theme.accent)
                    .font(.title3)
                    .padding(.leading, 16)
                TextField("username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .font(.body)
            }
            .background(Theme.card)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onChange(of: username) { _, newValue in
                username = newValue.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "_" }
            }

            mainButton(loading ? "Creating your world..." : "Create Account") {
                Task { await handleSignUp() }
            }
            .disabled(loading || username.count < 3)

            errorText
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Login
    private var loginView: some View {
        VStack(alignment: .leading, spacing: 16) {
            backButton { step = .welcome }

            Text("Welcome back")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundStyle(.white)

            TextField("Email", text: $email)
                .textFieldStyle(EuterpyTextFieldStyle())
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(EuterpyTextFieldStyle())

            mainButton(loading ? "Logging in..." : "Log In") {
                Task { await handleLogin() }
            }
            .disabled(loading)

            errorText
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Helpers
    @ViewBuilder
    private var errorText: some View {
        if let error {
            Text(error)
                .font(.caption)
                .foregroundStyle(.red)
        }
    }

    private func backButton(action: @escaping () -> Void) -> some View {
        Button("← Back", action: action)
            .font(.subheadline)
            .foregroundStyle(Theme.muted)
    }

    private func mainButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Theme.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Actions
    private func handleSignUp() async {
        error = nil
        guard username.count >= 3 else { error = "Username must be at least 3 characters"; return }
        loading = true
        defer { loading = false }

        do {
            try await authService.signUp(email: email, password: password, username: username)
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func handleLogin() async {
        error = nil
        loading = true
        defer { loading = false }

        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            self.error = error.localizedDescription
        }
    }
}

struct EuterpyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Theme.card)
            .foregroundStyle(.white)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .font(.body)
    }
}
