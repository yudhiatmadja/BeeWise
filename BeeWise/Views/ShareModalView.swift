//
//  ShareModalView.swift
//  BeeWise
//
//  Created by Mac on 05/11/26.
//

import SwiftUI
import CryptoKit

struct ShareModalView: View {
    @Environment(\.dismiss) var dismiss
    var points: Int
    var streak: Int = 0
    var percent: Double = 1
    var beeImage: String = "Bee_lv5"

    private var shareToken: String {
        let raw = "beewise-\(points)-\(streak)-\(beeImage)"
        let digest = SHA256.hash(data: Data(raw.utf8))
        return digest.map { String(format: "%02x", $0) }.joined().prefix(10).description
    }

    private var shareLink: String {
        "https://beewise.app/s/\(shareToken)"
    }

    private var shareText: String {
        "I collected \(points) points in BeeWise! \(shareLink)"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ShareCard(points: points, streak: streak, beeImage: beeImage)

                Text(shareLink)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)

                HStack(spacing: 28) {
                    Button {
                        copyLink()
                    } label: {
                        Image(systemName: "link")
                            .font(.title2)
                            .foregroundStyle(.black)
                            .frame(width: 58, height: 58)
                            .background(.gray.opacity(0.3))
                            .clipShape(.rect(cornerRadius: 14))
                    }

                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundStyle(.black)
                            .frame(width: 58, height: 58)
                            .background(.gray.opacity(0.3))
                            .clipShape(.rect(cornerRadius: 14))
                    }

                    ShareLink(item: shareText) {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundStyle(.black)
                            .frame(width: 58, height: 58)
                            .background(.gray.opacity(0.3))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                }
            }
            .navigationTitle("Share Your Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }

    private func copyLink() {
#if os(iOS)
        UIPasteboard.general.string = shareLink
#elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(shareLink, forType: .string)
#endif
    }
}

struct ShareCard: View {
    var points: Int
    var streak: Int = 0
    var beeImage: String = "Bee_lv5"

    @State private var floating = false
    @State private var displayedPoints = 0

    var body: some View {
        VStack(spacing: 8) {
            Image(beeImage)
                .resizable()
                .scaledToFit()
                .frame(height: 170)
                .offset(y: floating ? -10 : 10)
                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: floating)

            Text("\(displayedPoints)")
                .font(.system(size: 60, weight: .heavy))
                .padding(.top, 12)
                .onAppear {
                    floating = true
                    withAnimation(.easeOut(duration: 1.2)) {
                        displayedPoints = points
                    }
                }

            Text("Points Collected")
                .font(.subheadline)
                .fontWeight(.bold)

            if streak > 0 {
                HStack(spacing: 6) {
                    FlameIcon(size: 16)
                    Text("\(streak)-day streak")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(.white.opacity(0.4))
                .clipShape(Capsule())
            }

            Text("Congrats, You're So\nProductive Today")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
        }
        .foregroundStyle(.black)
        .frame(width: 270, height: 430)
        .background(
            LinearGradient(
                colors: [.yellow.opacity(0.8), .orange],
                startPoint: floating ? .topLeading : .top,
                endPoint: floating ? .bottomTrailing : .bottom
            )
            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: floating)
        )
        .clipShape(.rect(cornerRadius: 28))
    }
}

#Preview("Share Modal") {
    ShareModalView(points: 10, streak: 3, percent: 1, beeImage: "Bee_lv5")
}
