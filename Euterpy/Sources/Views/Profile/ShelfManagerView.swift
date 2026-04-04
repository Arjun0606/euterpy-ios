import SwiftUI

struct Shelf: Codable, Identifiable {
    let id: UUID
    let title: String
    let isFavorites: Bool
    let itemCount: Int

    enum CodingKeys: String, CodingKey {
        case id, title
        case isFavorites = "is_favorites"
        case itemCount = "item_count"
    }
}

struct ShelfManagerView: View {
    @Environment(AuthService.self) private var authService
    @State private var shelves: [Shelf] = []
    @State private var newShelfName = ""
    @State private var loading = true

    var body: some View {
        NavigationStack {
            List {
                // Existing shelves
                ForEach(shelves) { shelf in
                    HStack {
                        if shelf.isFavorites {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Theme.accent)
                                .font(.caption)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(shelf.isFavorites ? "★ Favorites" : shelf.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white)
                            Text("\(shelf.itemCount) items")
                                .font(.caption)
                                .foregroundStyle(Theme.muted)
                        }
                        Spacer()
                    }
                    .listRowBackground(Theme.card)
                }

                // Create new shelf
                HStack {
                    TextField("New shelf name...", text: $newShelfName)
                        .foregroundStyle(.white)
                        .font(.subheadline)
                    Button {
                        Task { await createShelf() }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Theme.accent)
                    }
                    .disabled(newShelfName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .listRowBackground(Theme.card)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Shelves")
            .navigationBarTitleDisplayMode(.inline)
            .task { await loadShelves() }
        }
    }

    private func loadShelves() async {
        guard let userId = authService.currentUser?.id else { return }
        do {
            shelves = try await authService.client
                .from("shelves")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("is_favorites", ascending: false)
                .order("created_at", ascending: false)
                .execute()
                .value
        } catch {
            print("Shelves error: \(error)")
        }
        loading = false
    }

    private func createShelf() async {
        guard let userId = authService.currentUser?.id else { return }
        let name = newShelfName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        do {
            try await authService.client
                .from("shelves")
                .insert(["user_id": userId.uuidString, "title": name])
                .execute()
            newShelfName = ""
            await loadShelves()
        } catch {
            print("Create shelf error: \(error)")
        }
    }
}
