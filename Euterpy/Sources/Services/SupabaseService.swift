import Foundation
import Supabase

/// The shared Supabase client. Single instance for the whole app.
///
/// Configured from Info.plist via EuterpyConfig — no hardcoded
/// credentials anywhere in source. The client is created lazily on
/// first access and reused for the lifetime of the process.
///
/// Date decoding strategy: ISO8601 with fractional seconds, which
/// matches Postgres `timestamptz` output through PostgREST.
///
/// Key decoding strategy: convert from snake_case so Codable models
/// can declare camelCase property names without per-property
/// CodingKeys boilerplate.
public final class SupabaseService {
    public static let shared = SupabaseService()

    public let client: SupabaseClient

    private init() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { dec in
            let container = try dec.singleValueContainer()
            let raw = try container.decode(String.self)

            // Try ISO8601 with fractional seconds first (Postgres default).
            let withFraction = ISO8601DateFormatter()
            withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = withFraction.date(from: raw) { return d }

            // Fallback: ISO8601 without fractional seconds.
            let plain = ISO8601DateFormatter()
            plain.formatOptions = [.withInternetDateTime]
            if let d = plain.date(from: raw) { return d }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unable to decode date string: \(raw)"
            )
        }

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601

        let options = SupabaseClientOptions(
            db: .init(encoder: encoder, decoder: decoder)
        )

        self.client = SupabaseClient(
            supabaseURL: EuterpyConfig.supabaseURL,
            supabaseKey: EuterpyConfig.supabaseAnonKey,
            options: options
        )
    }
}
