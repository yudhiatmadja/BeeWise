import SwiftUI
import Lottie

enum SuccessKind {
    case task
    case note

    var title: String {
        switch self {
        case .task: return "Task Created!"
        case .note: return "Note Created!"
        }
    }

    var message: String {
        switch self {
        case .task: return "Your task has been added\nto the list."
        case .note: return "Your note has been saved."
        }
    }

    var animation: String { "bee-success" }
    var hasAnimation: Bool {
        Bundle.main.url(forResource: animation, withExtension: "json") != nil
    }
}

struct SuccessModalView: View {
    @Binding var kind: SuccessKind?
    @State private var popped = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { kind = nil }

            VStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    if let kind, kind.hasAnimation {
                        LottieView(filename: kind.animation, loopMode: .loop)
                            .frame(width: 160, height: 160)
                    } else {
                        Image("bee")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                    }
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.green)
                        .background(.white, in: Circle())
                        .scaleEffect(popped ? 1 : 0.2)
                        .opacity(popped ? 1 : 0)
                }
                Text(kind?.title ?? "")
                    .font(.title2.bold())
                Text(kind?.message ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(28)
            .glassCard(cornerRadius: 28, tint: .white.opacity(0.7))
            .padding(.horizontal, 48)
            .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
        .onAppear {
            SoundManager.play(.shimmer)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.6).delay(0.15)) {
                popped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { kind = nil }
            }
        }
    }
}
