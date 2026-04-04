import SwiftUI

struct ProfileView: View {
    let username: String
    @Environment(AuthService.self) private var authService
    @State private var profile: Profile?
    @State private var ratings: [Rating] = []
    @State private var gtkmItems: [GetToKnowMeItem] = []
    @State private var loading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                if loading {
                    ProgressView()
                        .tint(Theme.accent)
                        .padding(.top, 60)
                } else if let profile {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        profileHeader(profile)

                        // Get to Know Me carousel
                        if !gtkmItems.isEmpty {
                            getToKnowMeSection
                        }

                        // Collection (record shelf)
                        if !ratings.isEmpty {
                            collectionSection
                        }
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
        }
        .task {
            await loadProfile()
        }
    }

    @ViewBuilder
    private func profileHeader(_ profile: Profile) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Avatar
            Circle()
                .fill(Theme.card)
                .frame(width: 72, height: 72)
                .overlay(
                    Text(profile.username.prefix(1).uppercased())
                        .font(.title2)
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
                    Text(bio)
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                        .padding(.top, 2)
                }

                HStack(spacing: 16) {
                    statView(count: profile.albumCount, label: "albums")
                    statView(count: profile.followerCount, label: "followers")
                    statView(count: profile.followingCount, label: "following")
                }
                .padding(.top, 8)
            }
        }
        .padding()
    }

    private func statView(count: Int, label: String) -> some View {
        HStack(spacing: 3) {
            Text("\(count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.muted)
        }
    }

    @ViewBuilder
    private var getToKnowMeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GET TO KNOW \(profile?.username.uppercased() ?? "")")
                .font(.caption2)
                .tracking(2)
                .foregroundStyle(Theme.muted)
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
        let labels = [
            "The album that shaped me",
            "The one I keep coming back to",
            "The one that changed everything",
        ]

        ZStack(alignment: .bottomLeading) {
            // Blurred background
            AsyncImage(url: album.artworkURL(size: 400)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Theme.card)
            }
            .frame(width: 300, height: 360)
            .blur(radius: 40)
            .opacity(0.3)
            .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.8), .black.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                VinylCoverView(artworkURL: album.artworkURL(size: 400), size: 140)
                    .padding(.bottom, 8)

                Text(labels[safe: item.position - 1] ?? "")
                    .font(.caption2)
                    .tracking(1.5)
                    .foregroundStyle(Theme.accent)
                    .textCase(.uppercase)

                Text(album.title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)

                if let story = item.story {
                    Text(""\(story)"")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .italic()
                        .lineLimit(3)
                        .padding(.top, 4)
                }
            }
            .padding(20)
        }
        .frame(width: 300, height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var collectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("COLLECTION")
                .font(.caption2)
                .tracking(2)
                .foregroundStyle(Theme.muted)
                .padding(.horizontal)

            // Grid of album covers (shelf style)
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(ratings) { rating in
                    if let album = rating.albums {
                        VStack(spacing: 4) {
                            AsyncImage(url: album.artworkURL(size: 300)) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle().fill(Theme.card)
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

                            StarRatingView(score: rating.score, size: 8)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 24)
    }

    private func loadProfile() async {
        do {
            let p: Profile = try await authService.client
                .from("profiles")
                .select()
                .eq("username", value: username)
                .single()
                .execute()
                .value
            profile = p

            let r: [Rating] = try await authService.client
                .from("ratings")
                .select("*, albums(*)")
                .eq("user_id", value: p.id.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value
            ratings = r

            let g: [GetToKnowMeItem] = try await authService.client
                .from("get_to_know_me")
                .select("*, albums(*)")
                .eq("user_id", value: p.id.uuidString)
                .order("position")
                .execute()
                .value
            gtkmItems = g
        } catch {
            print("Profile load error: \(error)")
        }
        loading = false
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
