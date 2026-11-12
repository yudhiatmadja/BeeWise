import SwiftUI
import Lottie

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    var onAction: () -> Void = {}

    var body: some View {
        VStack(spacing: 8) {
            LottieView(filename: "empty-box", loopMode: .loop)
                .frame(width: 220, height: 130)
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(action: onAction) {
                Text(buttonTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.honeyDeep, in: Capsule())
                    .shadow(color: Color.honeyDeep.opacity(0.4), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
