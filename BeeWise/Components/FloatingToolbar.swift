//
//  FloatingToolbar.swift
//  BeeWise
//
//  Created by Mac on 05/11/26.
//

import SwiftUI

struct FloatingToolbar: View {
    @Binding var selectedTab: String
    var onAdd: () -> Void
    
    @Namespace private var tabAnimation
    
    private let tabs: [(title: String, icon: String, isSystem: Bool)] = [
        ("Home", "house.fill", true),
        ("Pet", "honeycomb", false)
    ]
    
    var body: some View {
        ZStack {
            HStack(spacing: 8) {
                ForEach(tabs, id: \.title) { tab in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedTab = tab.title
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if tab.isSystem {
                                Image(systemName: tab.icon)
                            } else {
                                Image(tab.icon)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                            }
                            if selectedTab == tab.title {
                                Text(tab.title)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(selectedTab == tab.title ? .white : .primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background {
                            if selectedTab == tab.title {
                                Capsule()
                                    .fill(Color(.darkGray))
                                    .matchedGeometryEffect(id: "tabPill", in: tabAnimation)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
            .background(.ultraThinMaterial, in: Capsule())
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .blur(radius: 0)
            )
            .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
            
            if selectedTab == "Home" {
                HStack {
                    Spacer()
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(Color(red: 0.32, green: 0.43, blue: 0.48), in: Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                }
                .padding(.horizontal, 28)
                .offset(y: -40)
                .transition(.scale.combined(with: .opacity))
            }
        }
                .padding(.bottom, 4)
        }
    }

#Preview {
    FloatingToolbar(selectedTab: .constant("Home"), onAdd: {})
        .padding()
}
