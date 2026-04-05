import SwiftUI

enum ProfileTab: String, CaseIterable {
    case collection = "My Collection"
    case stats = "Stats"
    case reviews = "My Reviews"
}

struct ProfileView: View {
    let username: String
    @Environment(AuthService.self) private var authService
    @State private var profile: Profile?
    @State private var ratings: [Rating] = []
    @State private var songRatings: [SongRating] = []
    @State private var gtkmItems: [GetToKnowMeItem] = []
    @State private var reviews: [Review] = []
    @State private var badges: [UserBadge] = []
    @State private var loading = true
    @State private var activeTab: ProfileTab = .collection
    @State private var showGTKMEditor = false
    @State private var showShelfManager = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if loading {
                    ProgressView().tint(Theme.accent).padding(.top, 60)
                } else if let profile {
                    VStack(alignment: .leading, spacing: 0) {
                        profileHeader(profile)
                        tabBar
                        tabContent
                    }
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
            .sheet(isPresented: $showGTKMEditor) {
                GetToKnowMeEditor()
            }
            .sheet(isPresented: $showShelfManager) {
                ShelfManagerView()
            }
        }
        .task { await loadProfile() }
    }

    // MARK: - Header
    @ViewBuilder
    private func profileHeader(_ profile: Profile) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(Theme.card)
                .frame(width: 72, height: 72)
                .overlay(
                    Text(profile.username.prefix(1).uppercased())
                        .font(.system(size: 28, design: .serif))
                        .foregroundStyle(Theme.muted)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.displayName ?? profile.username)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                Text("@\(profile.username)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.accent)

                if let bio = profile.bio {
                    Text(""\(bio)"")
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                        .italic()
                        .padding(.top, 2)
                }

                // Stats
                HStack(spacing: 16) {
                    statView(count: profile.albumCount, label: "albums")
                    statView(count: profile.followerCount, label: "followers")
                    statView(count: profile.followingCount, label: "following")
                }
                .padding(.top, 8)

                // Badges
                if !badges.filter({ $0.isDisplayed }).isEmpty {
                    HStack(spacing: 4) {
                        ForEach(badges.filter { $0.isDisplayed }.prefix(5)) { ub in
                            Text(ub.badges?.icon ?? "")
                                .font(.title3)
                        }
                    }
                    .padding(.top, 4)
                }

                // Action buttons
                if authService.currentProfile?.username == username {
                    HStack(spacing: 8) {
                        Button("Share Profile") {}
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.accent)
                            .clipShape(Capsule())

                        NavigationLink("Edit Profile") {}
                            .font(.caption)
                            .foregroundStyle(Theme.muted)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .overlay(Capsule().stroke(Theme.border))
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding()
    }

    private func statView(count: Int, label: String) -> some View {
        HStack(spacing: 3) {
            Text("\(count)").font(.subheadline.weight(.semibold)).foregroundStyle(.white)
            Text(label).font(.caption).foregroundStyle(Theme.muted)
        }
    }

    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { activeTab = tab }
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(activeTab == tab ? Theme.accent : Theme.muted)
                        Rectangle()
                            .fill(activeTab == tab ? Theme.accent : .clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .overlay(alignment: .bottom) {
            Divider().background(Theme.border)
        }
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch activeTab {
        case .collection:
            collectionTab
        case .stats:
            statsTab
        case .reviews:
            reviewsTab
        }
    }

    // MARK: - Collection Tab
    private var collectionTab: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Edit buttons
            if authService.currentProfile?.username == username {
                HStack(spacing: 12) {
                    Button { showGTKMEditor = true } label: {
                        Label("Get to Know Me", systemImage: "square.stack.3d.up")
                            .font(.caption)
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.card)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Theme.border))
                    }
                    Button { showShelfManager = true } label: {
                        Label("Shelves", systemImage: "books.vertical")
                            .font(.caption)
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.card)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Theme.border))
                    }
                }
                .padding()
            }

            // Get to Know Me
            if !gtkmItems.isEmpty {
                getToKnowMeSection
            }

            // Collection grid
            if !ratings.isEmpty {
                collectionSection
            } else {
                Text("No albums rated yet.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                    .padding()
            }
        }
    }

    // MARK: - Stats Tab
    private var statsTab: some View {
        VStack {
            if ratings.isEmpty && songRatings.isEmpty {
                Text("No stats yet. Rate some albums.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                    .padding(.top, 40)
            } else {
                Text("Stats are available on the web at euterpy-web.vercel.app/\(username)/stats")
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
                    .multilineTextAlignment(.center)
                    .padding(32)
            }
        }
    }

    // MARK: - Reviews Tab
    private var reviewsTab: some View {
        VStack(alignment: .leading) {
            if reviews.isEmpty {
                VStack(spacing: 8) {
                    Text("No reviews yet.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                    Text("Write a review on any album page.")
                        .font(.caption)
                        .foregroundStyle(Theme.muted.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                ForEach(reviews) { review in
                    ReviewCard(review: review)
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - GTKM Section
    @ViewBuilder
    private var getToKnowMeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GET TO KNOW \(profile?.username.uppercased() ?? "")")
                .font(.caption2).tracking(2).foregroundStyle(Theme.muted)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(gtkmItems) { item in
                        if let album = item.albums {
                            gtkmCard(item: item, album: album)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 24)
    }

    @ViewBuilder
    private func gtkmCard(item: GetToKnowMeItem, album: Album) -> some View {
        let labels = ["The album that shaped me", "The one I keep coming back to", "The one that changed everything"]

        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: album.artworkURL(size: 400)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: { Rectangle().fill(Theme.card) }
            .frame(width: 300, height: 360).blur(radius: 40).opacity(0.3).clipped()

            LinearGradient(colors: [.clear, .black.opacity(0.8), .black.opacity(0.95)], startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 8) {
                VinylCoverView(artworkURL: album.artworkURL(size: 400), size: 140)
                    .padding(.bottom, 8)
                Text(labels[safe: item.position - 1] ?? "")
                    .font(.caption2).tracking(1.5).foregroundStyle(Theme.accent).textCase(.uppercase)
                Text(album.title)
                    .font(.title3.weight(.semibold)).foregroundStyle(.white)
                Text(album.artistName)
                    .font(.subheadline).foregroundStyle(Theme.muted)
                if let story = item.story {
                    Text(""\(story)"")
                        .font(.caption).foregroundStyle(.white.opacity(0.7)).italic().lineLimit(3).padding(.top, 4)
                }
            }
            .padding(20)
        }
        .frame(width: 300, height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }

    // MARK: - Collection Grid
    private var collectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("COLLECTION").font(.caption2).tracking(2).foregroundStyle(Theme.muted).padding(.horizontal)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(ratings) { rating in
                    if let album = rating.albums {
                        NavigationLink {
                            AlbumDetailView(album: album)
                        } label: {
                            VStack(spacing: 4) {
                                AsyncImage(url: album.artworkURL(size: 300)) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: { Rectangle().fill(Theme.card) }
                                .aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

                                StarRatingView(score: rating.score, size: 8)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Load
    private func loadProfile() async {
        do {
            let p: Profile = try await authService.client
                .from("profiles").select().eq("username", value: username).single().execute().value
            profile = p

            async let r: [Rating] = authService.client
                .from("ratings").select("*, albums(*)").eq("user_id", value: p.id.uuidString)
                .order("created_at", ascending: false).execute().value

            async let sr: [SongRating] = authService.client
                .from("song_ratings").select("*, songs(*)").eq("user_id", value: p.id.uuidString)
                .order("created_at", ascending: false).execute().value

            async let g: [GetToKnowMeItem] = authService.client
                .from("get_to_know_me").select("*, albums(*)").eq("user_id", value: p.id.uuidString)
                .order("position").execute().value

            ratings = try await r
            songRatings = try await sr
            gtkmItems = try await g
        } catch {
            print("Profile load error: \(error)")
        }
        loading = false
    }
}

// MARK: - Review Models
struct Review: Codable, Identifiable {
    let id: UUID
    let title: String?
    let body: String
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let isLoved: Bool
    let createdAt: String
    var albums: Album?
    var songs: Song?

    enum CodingKeys: String, CodingKey {
        case id, title, body, score, upvotes, downvotes, albums, songs
        case isLoved = "is_loved"
        case createdAt = "created_at"
    }
}

struct UserBadge: Codable, Identifiable {
    let id: UUID
    let isDisplayed: Bool
    var badges: Badge?

    enum CodingKeys: String, CodingKey {
        case id, badges
        case isDisplayed = "is_displayed"
    }
}

struct Badge: Codable {
    let name: String
    let description: String?
    let icon: String
}

struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let album = review.albums {
                    AsyncImage(url: album.artworkURL(size: 80)) { img in
                        img.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: { Rectangle().fill(Theme.card) }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                VStack(alignment: .leading) {
                    Text(review.albums?.title ?? review.songs?.title ?? "")
                        .font(.subheadline.weight(.medium)).foregroundStyle(.white)
                    Text(review.albums?.artistName ?? review.songs?.artistName ?? "")
                        .font(.caption).foregroundStyle(Theme.muted)
                }
                Spacer()
                StarRatingView(score: Double(review.score))
            }

            if let title = review.title {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
            }
            Text(review.body).font(.caption).foregroundStyle(Theme.muted).lineLimit(4)

            HStack {
                if review.isLoved {
                    Text("❤️ Users love this").font(.caption2).foregroundStyle(Theme.accent)
                }
                Spacer()
                Text("▲ \(review.upvotes) · ▼ \(review.downvotes)")
                    .font(.caption2).foregroundStyle(Theme.muted.opacity(0.5))
            }
        }
        .padding()
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border))
        .padding(.vertical, 4)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
