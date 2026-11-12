//
//  PetRoomView.swift
//  BeeWise
//
//  Created by Mac on 05/11/26.
//

import SwiftUI
import SwiftData

struct PetRoomView: View {
    @Query private var reminders: [ReminderModel]

    @AppStorage("petName") private var petName: String = "Pet Name"
    @AppStorage("streakCount") private var streakCount: Int = 0
    @AppStorage("lastStreakClaim") private var lastStreakClaim: String = ""
    @AppStorage("lastPenaltyClaim") private var lastPenaltyClaim: String = ""
    @AppStorage("evolutionPoints") private var evolutionPoints: Int = 0

    @State private var isEditingName: Bool = false
    @State private var showShareModal: Bool = false
    @State private var showTrophy = false
    @State private var lastSeenLevel: Int?

    private var todayTasks: [ReminderModel] {
        reminders.filter { r in
            guard let d = r.date else { return true }
            return Calendar.current.isDateInToday(d)
        }
    }

    private var todayDone: Int { todayTasks.filter { $0.isDone }.count }
    private var todayTotal: Int { todayTasks.count }
    private var percent: Double {
        guard todayTotal > 0 else { return 0 }
        return Double(todayDone) / Double(todayTotal)
    }
    private var isPerfect: Bool { todayTotal > 0 && todayDone == todayTotal }

    private var level: Int { min(evolutionPoints / 10, 4) + 1 }
    private var maxPoints: Int { 10 }
    private var progressInLevel: Int {
        level >= 5 ? maxPoints : evolutionPoints % 10
    }
    private var beeImage: String { "Bee_lv\(level)" }

    var body: some View {
        ZStack {
        HiveBackground()
        VStack(spacing: 24) {
            HStack {
                if isEditingName {
                    TextField("Pet Name", text: $petName, onCommit: {
                        isEditingName = false
                    })
                    .font(.title2)
                    .fontWeight(.bold)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(petName)
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Button(action: {
                    isEditingName.toggle()
                }) {
                    Image(systemName: isEditingName ? "checkmark" : "pencil")
                        .foregroundColor(isEditingName ? .green : .gray)
                }

                Spacer()

                Text("Level \(level)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(12)

                // penanda mode testing: hilang sendiri pas isProd = true
                if !BuildConfig.isProd {
                    Text("DEV ×\(BuildConfig.perfectDayPoints)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)

            VStack(spacing: 16) {
                Image(beeImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)
                    .id(beeImage)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: beeImage)

                VStack(spacing: 8) {
                    HStack {
                        Image("honey-jar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("Nectar")
                            .font(.caption)
                            .fontWeight(.bold)
                        Spacer()
                        Text(level >= 5 ? "MAX" : "\(progressInLevel) / \(maxPoints) pts")
                            .font(.caption)
                            .fontWeight(.bold)
                    }

                    ProgressView(value: Double(progressInLevel), total: Double(maxPoints))
                        .tint(.orange)
                        .animation(.easeInOut, value: progressInLevel)

                    Text("Today: \(todayDone) / \(todayTotal) tasks done")
                        .font(.caption2)
                        .foregroundColor(.gray)

                    HStack(spacing: 4) {
                        Text(level >= 5
                             ? "Max level reached!"
                             : "Complete \(maxPoints - progressInLevel) more perfect days to reach level \(level + 1)!")
                        if isPerfect {
                            Image(systemName: "party.popper.fill")
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.gray)
                }
            }
            .padding()
            .glassCard(cornerRadius: 20, tint: .white.opacity(0.5))
            .padding(.horizontal)

            if isPerfect {
                HStack(spacing: 12) {
                    FlameIcon(size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(streakCount)-day streak!")
                            .font(.headline)
                        HStack(spacing: 4) {
                            Text("Keep it up tomorrow")
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.caption)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .glassCard(cornerRadius: 20, tint: Color.orange.opacity(0.25))
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer()

            HStack {
                // tombol demo: hilang sendiri pas isProd = true
                if !BuildConfig.isProd {
                    Button("Test Trophy") { showTrophy = true }
                        .font(.caption2.bold())
                        .foregroundStyle(.purple)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                Spacer()
                Button(action: {
                    showShareModal = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 80)
        }
        .navigationTitle("Pet Room")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            lastSeenLevel = level
            claimStreakIfNeeded()
        }
        .onChange(of: level) { old, new in
            guard let last = lastSeenLevel, new > last else {
                lastSeenLevel = new
                return
            }
            lastSeenLevel = new
            showTrophy = true
        }
        .onChange(of: showTrophy) { _, new in
            if new { SoundManager.play(.fanfare) }
        }
        .onChange(of: isPerfect) { _, new in
            if new { SoundManager.play(.shimmer) }
        }
        .onChange(of: todayDone) { _, _ in claimStreakIfNeeded() }
        .sheet(isPresented: $showShareModal) {
            ShareModalView(points: evolutionPoints, streak: streakCount, percent: percent, beeImage: beeImage)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }

        if isPerfect {
            LottieView(filename: "confetti")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
                .ignoresSafeArea()
                .clipped()
        }

        if showTrophy {
            Color.black.opacity(0.35).ignoresSafeArea()
                .onTapGesture { showTrophy = false }
            VStack(spacing: 12) {
                LottieView(filename: "trophy")
                    .frame(width: 200, height: 200)
                Text("Level \(level) reached!")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Button("Awesome!") { showTrophy = false }
                    .buttonStyle(.borderedProminent)
            }
        }
        }
    }

    private func claimStreakIfNeeded() {
        applyPenaltyIfNeeded()
        guard isPerfect else { return }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let todayStr = fmt.string(from: .now)
        guard lastStreakClaim != todayStr else { return }
        let yesterdayStr = fmt.string(from: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now)
        streakCount = (lastStreakClaim == yesterdayStr) ? streakCount + 1 : 1
        lastStreakClaim = todayStr
        evolutionPoints += BuildConfig.perfectDayPoints
    }

    private func applyPenaltyIfNeeded() {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now) else { return }
        let yesterdayStr = fmt.string(from: yesterday)
        guard lastPenaltyClaim != yesterdayStr else { return }
        lastPenaltyClaim = yesterdayStr
        let tasks = reminders.filter { r in
            guard let d = r.date else { return false }
            return Calendar.current.isDate(d, inSameDayAs: yesterday)
        }
        guard !tasks.isEmpty else { return }
        if tasks.contains(where: { !$0.isDone }) {
            evolutionPoints = max(0, evolutionPoints - 1)
        }
    }
}

#Preview {
    NavigationStack {
        PetRoomView()
    }
    .modelContainer(for: [ReminderModel.self, NoteModel.self], inMemory: true)
}
