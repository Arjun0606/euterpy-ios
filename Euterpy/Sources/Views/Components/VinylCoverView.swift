import SwiftUI

struct VinylCoverView: View {
    let artworkURL: URL?
    let size: CGFloat
    var showVinyl: Bool = true

    var body: some View {
        ZStack(alignment: .trailing) {
            // Vinyl disc
            if showVinyl {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "1a1a1a"),
                                Color(hex: "111111"),
                                Color(hex: "1a1a1a"),
                                Color(hex: "111111"),
                                Color(hex: "1a1a1a"),
                                Color(hex: "222222"),
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.4
                        )
                    )
                    .frame(width: size * 0.8, height: size * 0.8)
                    .overlay(
                        // Center label
                        Circle()
                            .fill(Theme.accent)
                            .frame(width: size * 0.18, height: size * 0.18)
                            .overlay(
                                Circle()
                                    .fill(.black)
                                    .frame(width: size * 0.04, height: size * 0.04)
                            )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 2, y: 2)
                    .offset(x: size * 0.2)
            }

            // Album cover (sleeve)
            AsyncImage(url: artworkURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Theme.card)
                    .overlay(
                        Text("♪")
                            .font(.title)
                            .foregroundStyle(Theme.border)
                    )
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 4)
        }
    }
}
