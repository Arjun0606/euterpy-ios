import Foundation
import Observation
import Supabase

@Observable
class AuthService {
    var isAuthenticated = false
    var currentUser: User?
    var currentProfile: Profile?

    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
        supabaseKey: "YOUR_SUPABASE_ANON_KEY"
    )

    init() {
        Task {
            await checkSession()
        }
    }

    var client: SupabaseClient { supabase }

    func checkSession() async {
        do {
            let session = try await supabase.auth.session
            currentUser = session.user
            isAuthenticated = true
            await loadProfile()
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
    }

    func signUp(email: String, password: String, username: String) async throws {
        try await supabase.auth.signUp(
            email: email,
            password: password,
            data: ["username": .string(username)]
        )
        await checkSession()
    }

    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
        await checkSession()
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
        isAuthenticated = false
        currentUser = nil
        currentProfile = nil
    }

    private func loadProfile() async {
        guard let userId = currentUser?.id else { return }
        do {
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            currentProfile = profile
        } catch {
            print("Failed to load profile: \(error)")
        }
    }
}
