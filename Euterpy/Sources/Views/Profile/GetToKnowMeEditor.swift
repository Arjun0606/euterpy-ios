import SwiftUI

struct GetToKnowMeEditor: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @State private var items: [GetToKnowMeItem] = []
    @State private var editingPosition: Int? = nil
    @State private var searchQuery = ""
    @State private var searchResults: [MusicService.AlbumSearchResult] = []
    @State private var selectedAlbum: MusicService.AlbumSearchResult? = nil
    @State private var story = ""
    @State private var searching = false
    @State private var saving = false

    let labels = [
        "The album that shaped me",
        "The one I keep coming back to",
        "The one that changed everything",
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Current GTKM slots
                    ForEach(1...3, id: \.self) { position in
                        let item = items.first(where: { $0.position == position })

                        Button {
                            editingPosition = position
                            if let item, let album = item.albums {
                                story = item.story ?? ""
                            } else {
                                story = ""
                            }
                            selectedAlbum = nil
                            searchQuery = ""
                            searchResults = []
                        } label: {
                            HStack(spacing: 16) {
                                Text("\(position)")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(Theme.accent)
                                    .frame(width: 32)

                                if let album = item?.albums {
                                    AsyncImage(url: album.artworkURL(size: 100)) { image in
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle().fill(Theme.card)
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(album.title)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                        Text(album.artistName)
                                            .font(.caption)
                                            .foregroundStyle(Theme.muted)
                                        if let s = item?.story, !s.isEmpty {
                                            Text(""\(s)"")
                                                .font(.caption2)
                                                .foregroundStyle(Theme.muted.opacity(0.6))
                                                .italic()
                                                .lineLimit(1)
                                        }
                                    }
                                } else {
                                    Text(labels[position - 1])
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.muted.opacity(0.5))
                                        .italic()
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Theme.border)
                            }
                            .padding()
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(editingPosition == position ? Theme.accent : Theme.border, lineWidth: 1)
                            )
                        }
                    }

                    // Editor for selected position
                    if let pos = editingPosition {
                        VStack(spacing: 12) {
                            Divider().background(Theme.border)

                            Text("Set #\(pos): \(labels[pos - 1])")
                                .font(.caption)
                                .foregroundStyle(Theme.accent)

                            // Album search
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(Theme.muted)
                                TextField("Search album...", text: $searchQuery)
                                    .foregroundStyle(.white)
                                    .autocorrectionDisabled()
                                    .onChange(of: searchQuery) { _, q in
                                        searchAlbums(q)
                                    }
                            }
                            .padding(10)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border))

                            // Search results
                            if searching {
                                ProgressView().tint(Theme.accent)
                            }

                            ForEach(searchResults) { result in
                                Button {
                                    selectedAlbum = result
                                } label: {
                                    HStack(spacing: 10) {
                                        AsyncImage(url: result.artworkURL(size: 80)) { img in
                                            img.resizable().aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Rectangle().fill(Theme.card)
                                        }
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))

                                        VStack(alignment: .leading) {
                                            Text(result.title)
                                                .font(.caption.weight(.medium))
                                                .foregroundStyle(.white)
                                                .lineLimit(1)
                                            Text(result.artistName)
                                                .font(.caption2)
                                                .foregroundStyle(Theme.muted)
                                        }
                                        Spacer()
                                        if selectedAlbum?.appleId == result.appleId {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Theme.accent)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }

                            // Story
                            if selectedAlbum != nil {
                                TextField("Why this album?", text: $story, axis: .vertical)
                                    .lineLimit(3...5)
                                    .padding(10)
                                    .background(Theme.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border))
                                    .foregroundStyle(.white)
                                    .font(.caption)

                                Button {
                                    Task { await saveGTKM(position: pos) }
                                } label: {
                                    if saving {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Save")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(Theme.accent)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .disabled(saving)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Get to Know Me")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.accent)
                }
            }
            .task { await loadItems() }
        }
    }

    private func loadItems() async {
        guard let userId = authService.currentUser?.id else { return }
        do {
            let data: [GetToKnowMeItem] = try await authService.client
                .from("get_to_know_me")
                .select("*, albums(*)")
                .eq("user_id", value: userId.uuidString)
                .order("position")
                .execute()
                .value
            items = data
        } catch {
            print("GTKM load error: \(error)")
        }
    }

    private func searchAlbums(_ query: String) {
        guard query.count >= 2 else { searchResults = []; return }
        searching = true
        Task {
            do {
                searchResults = try await MusicService.shared.searchAlbums(query: query)
            } catch {
                searchResults = []
            }
            searching = false
        }
    }

    private func saveGTKM(position: Int) async {
        guard let userId = authService.currentUser?.id,
              let selected = selectedAlbum else { return }
        saving = true
        defer { saving = false }

        do {
            // Ensure album in DB
            let url = URL(string: "\(MusicService.shared.baseURL)/api/albums/\(selected.appleId)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AlbumDBResponse.self, from: data)
            guard let dbAlbum = response.album else { return }

            // Upsert
            try await authService.client
                .from("get_to_know_me")
                .upsert([
                    "user_id": userId.uuidString,
                    "position": "\(position)",
                    "album_id": dbAlbum.id.uuidString,
                    "story": story.isEmpty ? nil : story,
                ] as [String: String?], onConflict: "user_id,position")
                .execute()

            await loadItems()
            editingPosition = nil
        } catch {
            print("GTKM save error: \(error)")
        }
    }
}

private struct AlbumDBResponse: Codable {
    let album: AlbumDBRef?
}

private struct AlbumDBRef: Codable {
    let id: UUID
}
