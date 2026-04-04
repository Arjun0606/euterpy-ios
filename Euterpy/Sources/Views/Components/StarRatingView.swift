import SwiftUI

struct StarRatingView: View {
    let score: Double
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 1) {
            let fullStars = Int(score)
            let hasHalf = score.truncatingRemainder(dividingBy: 1) != 0

            ForEach(0..<fullStars, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: size))
                    .foregroundStyle(Theme.accent)
            }
            if hasHalf {
                Image(systemName: "star.leadinghalf.filled")
                    .font(.system(size: size))
                    .foregroundStyle(Theme.accent)
            }
        }
    }
}

struct StarRatingPicker: View {
    @Binding var score: Double
    var size: CGFloat = 32

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...10, id: \.self) { i in
                let value = Double(i) / 2.0
                let isFilled = value <= score

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        score = score == value ? 0 : value
                    }
                } label: {
                    Text("★")
                        .font(.system(size: size))
                        .foregroundStyle(isFilled ? Theme.accent : Theme.border)
                        .scaleEffect(i % 2 == 1 ? 0.7 : 1.0)
                }
                .sensoryFeedback(.selection, trigger: score)
            }
        }
    }
}
