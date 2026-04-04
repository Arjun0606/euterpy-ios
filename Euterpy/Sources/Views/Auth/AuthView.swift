import SwiftUI

struct AuthView: View {
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var error: String?
    @State private var loading = false
    @Environment(AuthService.self) private var authService

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            Text("Euterpy")
                .font(.system(size: 48, weight: .regular, design: .serif))
                .foregroundStyle(.white)

            Text("Your music taste, curated.")
                .font(.subheadline)
                .foregroundStyle(Theme.muted)
                .padding(.top, 4)
                .padding(.bottom, 40)

            // Form
            VStack(spacing: 12) {
                if !isLogin {
                    TextField("Username", text: $username)
                        .textFieldStyle(EuterpyTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                TextField("Email", text: $email)
                    .textFieldStyle(EuterpyTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(EuterpyTextFieldStyle())

                if let error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Button(action: handleSubmit) {
                    if loading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isLogin ? "Log In" : "Create Account")
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Theme.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(loading)
            }
            .padding(.horizontal, 32)

            // Toggle
            Button(isLogin ? "Don't have an account? Sign up" : "Already have an account? Log in") {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isLogin.toggle()
                    error = nil
                }
            }
            .font(.caption)
            .foregroundStyle(Theme.accent)
            .padding(.top, 20)

            Spacer()
        }
        .background(Theme.background)
    }

    private func handleSubmit() {
        error = nil
        loading = true

        Task {
            do {
                if isLogin {
                    try await authService.signIn(email: email, password: password)
                } else {
                    guard username.count >= 3 else {
                        error = "Username must be at least 3 characters"
                        loading = false
                        return
                    }
                    try await authService.signUp(email: email, password: password, username: username.lowercased())
                }
            } catch {
                self.error = error.localizedDescription
            }
            loading = false
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
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .font(.subheadline)
    }
}
