import SwiftUI

/// User avatar — circle, with optional image URL and a fallback to
/// the initial letter inside a bordered circle. Used everywhere
/// from the profile header (size .xl) to comment rows (size .xs).
///
/// Five sizes match the points the design uses across the app. Adding
/// a new size means adding a case here, not picking arbitrary
/// numbers in a view.
public struct Avatar: View {
    public enum Size {
        case xs   // 28pt — comment rows, dense lists
        case sm   // 36pt — notification rows, follow buttons
        case md   // 48pt — list rows, story author byline
        case lg   // 64pt — profile cards on follower lists
        case xl   // 96pt — the profile page header

        var dimension: CGFloat {
            switch self {
            case .xs: return 28
            case .sm: return 36
            case .md: return 48
            case .lg: return 64
            case .xl: return 96
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .xs: return 11
            case .sm: return 14
            case .md: return 18
            case .lg: return 24
            case .xl: return 36
            }
        }
    }

    let url: String?
    let username: String?
    let size: Size

    public init(url: String?, username: String?, size: Size = .md) {
        self.url = url
        self.username = username
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(EuterpyColor.card)
            .frame(width: size.dimension, height: size.dimension)
            .overlay(
                Circle().strokeBorder(EuterpyColor.border, lineWidth: 1)
            )
            .overlay {
                if let url, let imageURL = URL(string: url) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            initialView
                        }
                    }
                    .clipShape(Circle())
                } else {
                    initialView
                }
            }
    }

    private var initialView: some View {
        Text(initial)
            .font(.system(size: size.fontSize, weight: .medium, design: .serif))
            .foregroundStyle(EuterpyColor.mutedDeep)
    }

    private var initial: String {
        guard let username, let first = username.first else { return "?" }
        return String(first).uppercased()
    }
}

#Preview {
    HStack(spacing: 16) {
        Avatar(url: nil, username: "arjun", size: .xs)
        Avatar(url: nil, username: "arjun", size: .sm)
        Avatar(url: nil, username: "arjun", size: .md)
        Avatar(url: nil, username: "arjun", size: .lg)
        Avatar(url: nil, username: "arjun", size: .xl)
    }
    .padding()
    .background(EuterpyColor.background)
    .preferredColorScheme(.dark)
}
