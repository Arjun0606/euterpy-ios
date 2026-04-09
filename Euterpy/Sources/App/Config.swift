import Foundation

/// Global configuration. Reads from `Info.plist` so secrets and
/// environment-specific values never live in source code.
///
/// In v1 the Supabase anon key was hardcoded inside `AuthService.swift`,
/// which made the credentials show up in `git grep` and made it
/// impossible to run a separate staging environment without
/// recompiling. We're not doing that again.
///
/// To populate these values, set them in your `.xcconfig` file
/// (or directly in the Xcode build settings) and reference them
/// from `Info.plist`. Example `.xcconfig` entries:
///
///     SUPABASE_URL = https:/$()/abc.supabase.co
///     SUPABASE_ANON_KEY = eyJhbGciOi...
///     EUTERPY_WEB_BASE_URL = https:/$()/euterpy.com
///
/// Then in `Info.plist`:
///
///     <key>SupabaseURL</key>
///     <string>$(SUPABASE_URL)</string>
///     <key>SupabaseAnonKey</key>
///     <string>$(SUPABASE_ANON_KEY)</string>
///     <key>EuterpyWebBaseURL</key>
///     <string>$(EUTERPY_WEB_BASE_URL)</string>
///
/// The `$()` interpolation in the .xcconfig comments above is
/// escaped because Xcode treats `//` as a comment delimiter and
/// would otherwise truncate the URL.
enum EuterpyConfig {
    /// The Supabase project URL. Same backend as the web app —
    /// both clients read and write the same database, so a story
    /// you write on iOS appears on web instantly and vice versa.
    static var supabaseURL: URL {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "SupabaseURL") as? String,
            let url = URL(string: raw)
        else {
            fatalError(
                """
                Missing or invalid SupabaseURL in Info.plist.
                Set SUPABASE_URL in your .xcconfig and reference it
                from Info.plist as $(SUPABASE_URL).
                """
            )
        }
        return url
    }

    /// The Supabase anonymous key. This is safe to ship in the
    /// binary by design — Supabase auth + RLS gate everything,
    /// the anon key has no superuser power. We still keep it out
    /// of source so it's auditable in one place and rotatable
    /// without a code change.
    static var supabaseAnonKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SupabaseAnonKey") as? String, !key.isEmpty else {
            fatalError(
                """
                Missing SupabaseAnonKey in Info.plist.
                Set SUPABASE_ANON_KEY in your .xcconfig.
                """
            )
        }
        return key
    }

    /// The base URL of the Euterpy web app. iOS calls into this
    /// for the literary/editorial layer:
    ///
    ///   - GET /api/notifications/render?id=…
    ///   - GET /api/curators/status/:userId
    ///   - GET /api/memories/on-this-day
    ///   - GET /api/first-friday/state
    ///   - GET /api/annual/:userId/:year
    ///   - GET /api/songs/search and /api/albums/search (catalog)
    ///
    /// Hybrid architecture: native iOS rendering + shared backend
    /// rules. When we tweak notification copy on the web, iOS sees
    /// the new copy on the very next request. Zero drift.
    static var webBaseURL: URL {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "EuterpyWebBaseURL") as? String,
            let url = URL(string: raw)
        else {
            // Reasonable production default — overridable for staging.
            return URL(string: "https://euterpy.com")!
        }
        return url
    }
}
