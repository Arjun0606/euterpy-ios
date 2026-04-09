import Foundation
import Supabase
import Observation

/// Auth state for the whole app. Single source of truth — every view
/// that needs to know who the current user is reaches into this
/// `@Observable` class via the environment, instead of querying
/// Supabase directly. This means a sign-in / sign-out anywhere
/// causes a re-render everywhere automatically.
///
/// We listen to Supabase auth state changes via the SDK's
/// `authStateChanges` async stream, so token refresh, sign-out from
/// another device, and expired sessions all flow through one place.
///
/// `currentProfile` is loaded after sign-in by ProfileRepository so
/// the rest of the app can render the user's display name + avatar
/// without an extra round-trip per view.
@Observable
public final class AuthService {
    public enum State: Equatable {
        case loading
        case signedIn(userId: String)
        case signedOut
    }

    public private(set) var state: State = .loading
    public private(set) var currentUserId: String?
    public private(set) var currentProfile: Profile?

    private let client = SupabaseService.shared.client
    private var listenerTask: Task<Void, Never>?

    public init() {}

    /// Start listening to auth state changes. Call once from
    /// EuterpyApp's `init()`. The listener is held for the lifetime
    /// of the app — auth state can change at any moment (token
    /// refresh, remote sign-out, etc.) and the UI needs to follow.
    public func start() {
        // Initial session check.
        Task {
            do {
                let session = try await client.auth.session
                await MainActor.run {
                    self.currentUserId = session.user.id.uuidString
                    self.state = .signedIn(userId: session.user.id.uuidString)
                }
                await loadProfile()
            } catch {
                await MainActor.run {
                    self.state = .signedOut
                    self.currentUserId = nil
                    self.currentProfile = nil
                }
            }
        }

        // Long-running listener for subsequent changes.
        listenerTask = Task { [weak self] in
            guard let self else { return }
            for await (event, session) in client.auth.authStateChanges {
                switch event {
                case .signedIn, .tokenRefreshed, .userUpdated:
                    if let session {
                        await MainActor.run {
                            self.currentUserId = session.user.id.uuidString
                            self.state = .signedIn(userId: session.user.id.uuidString)
                        }
                        await self.loadProfile()
                    }
                case .signedOut, .userDeleted:
                    await MainActor.run {
                        self.state = .signedOut
                        self.currentUserId = nil
                        self.currentProfile = nil
                    }
                default:
                    break
                }
            }
        }
    }

    /// Pull the current user's profile row into memory. Called on
    /// sign-in and after profile updates. Errors are swallowed
    /// because a missing profile shouldn't break the app — the
    /// trigger that creates a profile row on signup may be racing
    /// with the auth callback on the very first sign-in.
    public func loadProfile() async {
        guard let userId = currentUserId else { return }
        do {
            let profile: Profile = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            await MainActor.run {
                self.currentProfile = profile
            }
        } catch {
            // Profile may not exist yet on first sign-in (trigger
            // race). The next loadProfile() call will pick it up.
        }
    }

    // MARK: - Sign in / Sign up / Sign out

    public func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
        // The auth state listener handles the rest — sets state,
        // loads profile, etc. Caller doesn't need to do anything else.
    }

    public func signUp(email: String, password: String, username: String) async throws {
        // Username is stored in user metadata so the database trigger
        // that creates a profiles row on signup can pick it up.
        try await client.auth.signUp(
            email: email,
            password: password,
            data: ["username": .string(username)]
        )
    }

    public func signOut() async {
        do {
            try await client.auth.signOut()
        } catch {
            // Even if the server-side sign-out fails (e.g. offline)
            // we still want to clear local state — otherwise the
            // user is stuck logged in with no way out.
            await MainActor.run {
                self.state = .signedOut
                self.currentUserId = nil
                self.currentProfile = nil
            }
        }
    }

    deinit {
        listenerTask?.cancel()
    }
}
