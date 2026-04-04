import SwiftUI

struct StarRatingView: View {
    let score: Double
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= Int(score.rounded()) ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(i <= Int(score.rounded()) ? Theme.accent : Theme.border)
            }
        }
    }
}

struct StarRatingPicker: View {
    @Binding var score: Double
    var size: CGFloat = 32

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { i in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        score = score == Double(i) ? 0 : Double(i)
                    }
                } label: {
                    Image(systemName: Double(i) <= score ? "star.fill" : "star")
                        .font(.system(size: size))
                        .foregroundStyle(Double(i) <= score ? Theme.accent : Theme.border)
                }
                .sensoryFeedback(.selection, trigger: score)
            }
        }
    }
}
