//
//  Theme.swift
//  BeeWise
//
//  Created by Mac on 05/11/26.
//

import SwiftUI

extension Color {
    static let slate = Color(red: 0.32, green: 0.43, blue: 0.48)
    static let card = Color(red: 0.84, green: 0.87, blue: 0.89)
    static let honey = Color(red: 0.98, green: 0.75, blue: 0.25)
    static let honeyDeep = Color(red: 0.93, green: 0.62, blue: 0.14)
}

/// Background tematik sarang lebah: gradien langit pagi -> krim -> madu,
/// plus awan dan aset honeycomb dari katalog. Dipakai semua screen.
struct HiveBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.80, green: 0.91, blue: 0.97),
                Color(red: 0.99, green: 0.96, blue: 0.88),
                Color(red: 0.99, green: 0.90, blue: 0.70),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay {
            GeometryReader { geo in
                ZStack {
                    // awan
                    CloudShape()
                        .fill(.white.opacity(0.55))
                        .frame(width: 150, height: 48)
                        .position(x: geo.size.width * 0.2, y: 90)
                    CloudShape()
                        .fill(.white.opacity(0.4))
                        .frame(width: 110, height: 36)
                        .position(x: geo.size.width * 0.82, y: 150)
                    // sarang dari aset katalog
                    Image("honey-comb-bg")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.35)
                        .frame(width: 220)
                        .position(x: geo.size.width * 0.9, y: geo.size.height * 0.8)
                    Image("honey-comb-bg2")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.25)
                        .frame(width: 150)
                        .position(x: geo.size.width * 0.08, y: geo.size.height * 0.5)
                }
            }
        }
        .ignoresSafeArea()
    }
}

/// Glass theme: material kaca + border highlight + shadow lembut.
/// Dipakai untuk card dan komponen animasi biar menyatu dengan background.
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 22
    var tint: Color? = nil
    var borderOpacity: Double = 0.5

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(tint ?? .clear)
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(borderOpacity), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 22, tint: Color? = nil) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, tint: tint))
    }
}

private struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addEllipse(in: CGRect(x: 0, y: rect.height * 0.35, width: rect.width * 0.45, height: rect.height * 0.65))
        p.addEllipse(in: CGRect(x: rect.width * 0.25, y: 0, width: rect.width * 0.5, height: rect.height))
        p.addEllipse(in: CGRect(x: rect.width * 0.55, y: rect.height * 0.35, width: rect.width * 0.45, height: rect.height * 0.65))
        return p
    }
}

struct FlameIcon: View {
    var size: CGFloat = 28

    @State private var flicker = false

    var body: some View {
        Image(systemName: "flame.fill")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(
                LinearGradient(
                    colors: [.yellow, .orange, .red],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .scaleEffect(flicker ? 1.12 : 0.94, anchor: .bottom)
            .rotationEffect(.degrees(flicker ? -3 : 3), anchor: .bottom)
            .shadow(color: .orange.opacity(0.55), radius: flicker ? 10 : 4)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                    flicker.toggle()
                }
            }
    }
}
