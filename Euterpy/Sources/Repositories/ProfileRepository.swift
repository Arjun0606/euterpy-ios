import Foundation
import Supabase

/// All reads and writes against the `public.profiles` table.
///
/// The pattern: every Repository has exactly one responsibility — its
/// own table — and exposes async methods that return Models. Views
/// never call Supabase directly. This gives us one place to put
/// caching, logging, retry logic, and tests, and means refactoring
/// the database schema only ever touches one file per table.
public final class ProfileRepository {
    public static let shared = ProfileRepository()

    private let client = SupabaseService.shared.client

    private init() {}

    /// Fetch a profile by username. Used by every public profile page.
    public func fetchByUsername(_ username: String) async throws -> Profile? {
        do {
            let profile: Profile = try await client
                .from("profiles")
                .select()
                .eq("username", value: username)
                .single()
                .execute()
                .value
            return profile
        } catch {
            // PostgREST throws if .single() finds zero rows; that's a
            // legitimate "not found," not an error to surface.
            return nil
        }
    }

    /// Fetch a profile by id. Used by repositories that have joined
    /// foreign-key data and need the full profile.
    public func fetchById(_ id: String) async throws -> Profile? {
        do {
            let profile: Profile = try await client
                .from("profiles")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            return profile
        } catch {
            return nil
        }
    }

    /// Update the editable fields on the current user's profile.
    /// Username is intentionally not updatable.
    public func update(
        userId: String,
        displayName: String?,
        bio: String?
    ) async throws {
        struct Patch: Encodable {
            let displayName: String?
            let bio: String?
        }
        try await client
            .from("profiles")
            .update(Patch(displayName: displayName, bio: bio))
            .eq("id", value: userId)
            .execute()
    }
}
