import SwiftUI

struct RateAlbumSheet: View {
    let album: Album
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @State private var score: Double = 0
    @State private var reaction = ""
    @State private var ownership = "digital"
    @State private var saving = false

    let ownershipOptions = [
        ("vinyl", "🎵 Vinyl"),
        ("cd", "💿 CD"),
        ("cassette", "📼 Cassette"),
        ("digital", "🎧 Stream"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Album info
                HStack(spacing: 16) {
                    AsyncImage(url: album.artworkURL(size: 200)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle().fill(Theme.card)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(album.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        Text(album.artistName)
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }
                    Spacer()
                }
                .padding(.top, 8)

                // Star rating
                VStack(spacing: 8) {
                    StarRatingPicker(score: $score, size: 28)
                    Text(score > 0 ? "\(String(format: "%.1f", score)) / 5" : "Tap to rate")
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                }

                // Reaction
                VStack(alignment: .leading, spacing: 6) {
                    Text("Say something...")
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                    TextField("Track 6 broke me.", text: $reaction)
                        .textFieldStyle(EuterpyTextFieldStyle())
                }

                // Ownership
                VStack(alignment: .leading, spacing: 8) {
                    Text("How do you own it?")
                        .font(.caption)
                        .foregroundStyle(Theme.muted)

                    HStack(spacing: 8) {
                        ForEach(ownershipOptions, id: \.0) { option in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    ownership = option.0
                                }
                            } label: {
                                Text(option.1)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(ownership == option.0 ? Theme.accent : Theme.card)
                                    .foregroundStyle(ownership == option.0 ? .white : Theme.muted)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(ownership == option.0 ? .clear : Theme.border, lineWidth: 1)
                                    )
                            }
                            .sensoryFeedback(.selection, trigger: ownership)
                        }
                    }
                }

                Spacer()

                // Submit
                Button {
                    Task { await submitRating() }
                } label: {
                    if saving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Log Album")
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(score > 0 ? Theme.accent : Theme.border)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(score == 0 || saving)
            }
            .padding()
            .background(Theme.background)
            .navigationTitle("Rate Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.muted)
                }
            }
        }
    }

    private func submitRating() async {
        saving = true
        defer { saving = false }

        guard let userId = authService.currentUser?.id else { return }

        do {
            // Ensure album exists in DB via web API
            let url = URL(string: "\(MusicService.shared.baseURL)/api/albums/\(album.appleId)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AlbumResponse.self, from: data)
            guard let dbAlbum = response.album else { return }

            // Insert rating
            try await authService.client
                .from("ratings")
                .insert([
                    "user_id": userId.uuidString,
                    "album_id": dbAlbum.id.uuidString,
                    "score": "\(score)",
                    "reaction": reaction.isEmpty ? nil : reaction,
                    "ownership": ownership,
                ] as [String: String?])
                .execute()

            dismiss()
        } catch {
            print("Rating error: \(error)")
        }
    }
}

private struct AlbumResponse: Codable {
    let album: AlbumDB?
}

private struct AlbumDB: Codable {
    let id: UUID
}
