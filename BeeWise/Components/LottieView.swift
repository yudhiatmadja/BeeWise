import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let filename: String
    var loopMode: LottieLoopMode = .playOnce
    var animationSpeed: CGFloat = 1.0

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: filename)
        view.loopMode = loopMode
        view.animationSpeed = animationSpeed
        view.contentMode = .scaleAspectFit
        view.backgroundBehavior = .pauseAndRestore
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
