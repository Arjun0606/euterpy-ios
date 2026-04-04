import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @Environment(AuthService.self) private var authService
    @State private var showRating = false
    @State private var tracks: [TrackItem] = []
    @State private var loadingTracks = true

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Album art hero with blurred background
                ZStack {
                    AsyncImage(url: album.artworkURL(size: 200)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle().fill(Theme.card)
                    }
                    .frame(height: 300)
                    .blur(radius: 60)
                    .opacity(0.15)
                    .clipped()

                    LinearGradient(
                        colors: [.clear, Theme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(spacing: 16) {
                        VinylCoverView(
                            artworkURL: album.artworkURL(size: 600),
                            size: 200
                        )

                        Text(album.title)
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text(album.artistName)
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)

                        if let date = album.releaseDate {
                            Text(String(date.prefix(4)))
                                .font(.caption)
                                .foregroundStyle(Theme.muted.opacity(0.5))
                        }

                        if let avg = album.averageRating, album.ratingCount > 0 {
                            HStack(spacing: 4) {
                                Text(String(format: "%.1f", avg))
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(Theme.accent)
                                Text("/ 5 from \(album.ratingCount) \(album.ratingCount == 1 ? "rating" : "ratings")")
                                    .font(.caption)
                                    .foregroundStyle(Theme.muted)
                            }
                        }

                        // Rate button
                        Button {
                            showRating = true
                        } label: {
                            Text("Rate Album")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 140, height: 40)
                                .background(Theme.accent)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 40)
                }
                .frame(height: 480)

                // Tracks
                if !tracks.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("TRACKS")
                            .font(.caption2)
                            .tracking(2)
                            .foregroundStyle(Theme.muted)
                            .padding(.horizontal)
                            .padding(.bottom, 12)

                        ForEach(tracks) { track in
                            HStack(spacing: 12) {
                                Text("\(track.trackNumber)")
                                    .font(.caption)
                                    .foregroundStyle(Theme.muted.opacity(0.4))
                                    .frame(width: 24, alignment: .trailing)
                                    .monospacedDigit()

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(track.title)
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Text(track.artistName)
                                        .font(.caption)
                                        .foregroundStyle(Theme.muted.opacity(0.6))
                                }

                                Spacer()

                                Text(track.formattedDuration)
                                    .font(.caption)
                                    .foregroundStyle(Theme.muted.opacity(0.4))
                                    .monospacedDigit()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)

                            if track.id != tracks.last?.id {
                                Divider()
                                    .background(Theme.border.opacity(0.5))
                                    .padding(.leading, 52)
                            }
                        }
                    }
                    .padding(.top, 24)
                } else if loadingTracks {
                    ProgressView()
                        .tint(Theme.accent)
                        .padding(.top, 24)
                }
            }
        }
        .background(Theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRating) {
            RateAlbumSheet(album: album)
        }
        .task {
            await loadTracks()
        }
    }

    private func loadTracks() async {
        do {
            let url = URL(string: "\(MusicService.shared.baseURL)/api/albums/\(album.appleId)/tracks")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(TracksResponse.self, from: data)
            tracks = response.tracks
        } catch {
            print("Failed to load tracks: \(error)")
        }
        loadingTracks = false
    }
}

struct TracksResponse: Codable {
    let tracks: [TrackItem]
}

struct TrackItem: Codable, Identifiable {
    let appleId: String
    let title: String
    let artistName: String
    let trackNumber: Int
    let durationMs: Int

    var id: String { appleId }

    var formattedDuration: String {
        let mins = durationMs / 60000
        let secs = (durationMs % 60000) / 1000
        return "\(mins):\(String(format: "%02d", secs))"
    }
}
