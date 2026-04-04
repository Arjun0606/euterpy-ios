import SwiftUI

enum SearchTab: String, CaseIterable {
    case albums = "Albums"
    case songs = "Songs"
}

struct SearchView: View {
    @State private var query = ""
    @State private var tab: SearchTab = .albums
    @State private var albumResults: [MusicService.AlbumSearchResult] = []
    @State private var songResults: [MusicService.SongSearchResult] = []
    @State private var loading = false
    @State private var searched = false
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.muted)
                    TextField(tab == .albums ? "Search albums..." : "Search songs...", text: $query)
                        .foregroundStyle(.white)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: query) { _, newValue in
                            debounceSearch(newValue)
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.border, lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top, 8)

                // Tabs
                HStack(spacing: 0) {
                    ForEach(SearchTab.allCases, id: \.self) { t in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                tab = t
                            }
                            if query.count >= 2 { performSearch() }
                        } label: {
                            Text(t.rawValue)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(tab == t ? .white : Theme.muted)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(tab == t ? Theme.accent : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(4)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.border, lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top, 12)

                // Results
                ScrollView {
                    if loading {
                        ProgressView()
                            .tint(Theme.accent)
                            .padding(.top, 40)
                    } else if searched && albumResults.isEmpty && songResults.isEmpty {
                        Text("No \(tab.rawValue.lowercased()) found.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                            .padding(.top, 40)
                    } else if tab == .albums {
                        LazyVStack(spacing: 2) {
                            ForEach(albumResults) { album in
                                AlbumSearchRow(album: album)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        LazyVStack(spacing: 2) {
                            ForEach(songResults) { song in
                                SongSearchRow(song: song)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
            }
            .background(Theme.background)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Search")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func debounceSearch(_ query: String) {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            if !Task.isCancelled {
                performSearch()
            }
        }
    }

    private func performSearch() {
        guard query.count >= 2 else {
            albumResults = []
            songResults = []
            searched = false
            return
        }

        loading = true
        searched = true

        Task {
            do {
                if tab == .albums {
                    albumResults = try await MusicService.shared.searchAlbums(query: query)
                } else {
                    songResults = try await MusicService.shared.searchSongs(query: query)
                }
            } catch {
                print("Search error: \(error)")
            }
            loading = false
        }
    }
}

struct AlbumSearchRow: View {
    let album: MusicService.AlbumSearchResult

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: album.artworkURL(size: 112)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Theme.card)
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(album.artistName)
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
                    .lineLimit(1)
                if let date = album.releaseDate {
                    Text(String(date.prefix(4)))
                        .font(.caption2)
                        .foregroundStyle(Theme.muted.opacity(0.5))
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct SongSearchRow: View {
    let song: MusicService.SongSearchResult

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: song.artworkURL(size: 88)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Theme.card)
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text(song.artistName)
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                    if let albumName = song.albumName {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(Theme.muted.opacity(0.4))
                        Text(albumName)
                            .font(.caption)
                            .foregroundStyle(Theme.muted.opacity(0.4))
                    }
                }
                .lineLimit(1)
            }

            Spacer()

            Text(song.formattedDuration)
                .font(.caption2)
                .foregroundStyle(Theme.muted.opacity(0.4))
                .monospacedDigit()
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

extension MusicService.AlbumSearchResult {
    func artworkURL(size: Int = 500) -> URL? {
        guard let template = artworkUrl else { return nil }
        let resolved = template
            .replacingOccurrences(of: "{w}", with: "\(size)")
            .replacingOccurrences(of: "{h}", with: "\(size)")
        return URL(string: resolved)
    }
}

extension MusicService.SongSearchResult {
    func artworkURL(size: Int = 300) -> URL? {
        guard let template = artworkUrl else { return nil }
        let resolved = template
            .replacingOccurrences(of: "{w}", with: "\(size)")
            .replacingOccurrences(of: "{h}", with: "\(size)")
        return URL(string: resolved)
    }
}
