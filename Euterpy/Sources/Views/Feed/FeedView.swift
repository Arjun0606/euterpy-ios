import SwiftUI

struct FeedView: View {
    @Environment(AuthService.self) private var authService
    @State private var feedItems: [FeedItem] = []
    @State private var loading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                if loading {
                    ProgressView()
                        .tint(Theme.accent)
                        .padding(.top, 60)
                } else if feedItems.isEmpty {
                    VStack(spacing: 8) {
                        Text("Your feed is empty.")
                            .foregroundStyle(Theme.muted)
                        Text("Follow people or search for an album to log.")
                            .font(.caption)
                            .foregroundStyle(Theme.muted.opacity(0.6))
                    }
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 2) {
                        ForEach(feedItems) { item in
                            FeedItemRow(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Theme.background)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Euterpy")
                        .font(.system(size: 24, weight: .regular, design: .serif))
                        .foregroundStyle(.white)
                }
            }
            .toolbarBackground(Theme.background, for: .navigationBar)
        }
        .task {
            await loadFeed()
        }
    }

    private func loadFeed() async {
        guard let userId = authService.currentUser?.id else { return }
        do {
            let items: [FeedItem] = try await authService.client
                .from("feed_items")
                .select("*, actor:profiles!feed_items_actor_id_fkey(*), rating:ratings!feed_items_rating_id_fkey(*, albums(*))")
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
            feedItems = items
        } catch {
            print("Feed load error: \(error)")
        }
        loading = false
    }
}

struct FeedItemRow: View {
    let item: FeedItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            Circle()
                .fill(Theme.card)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(item.actor?.username.prefix(1).uppercased() ?? "?")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                )

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(item.actor?.displayName ?? item.actor?.username ?? "")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                    Text("rated")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                }

                if let album = item.rating?.albums {
                    Text(album.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                    Text(album.artistName)
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                }

                if let score = item.rating?.score {
                    StarRatingView(score: score)
                }

                if let reaction = item.rating?.reaction {
                    Text(""\(reaction)"")
                        .font(.caption)
                        .foregroundStyle(Theme.muted.opacity(0.8))
                        .italic()
                        .padding(.top, 2)
                }
            }

            Spacer()

            // Album art
            if let album = item.rating?.albums {
                AsyncImage(url: album.artworkURL(size: 112)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Theme.card)
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}
