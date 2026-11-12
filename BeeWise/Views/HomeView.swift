//
//  HomeView.swift
//  BeeWise
//
//  Created by Mac on 03/11/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \NoteModel.createdAt, order: .reverse)
    private var allNotes: [NoteModel]
    @Query(sort: \ReminderModel.createdAt, order: .reverse)
    private var reminders: [ReminderModel]

    private var activeNotesCount: Int { allNotes.filter { !$0.isDone }.count }

    private var todayTasks: [ReminderModel] {
        reminders.filter { r in
            guard let d = r.date else { return true }
            return Calendar.current.isDateInToday(d)
        }
    }
    private var todayDone: Int { todayTasks.filter { $0.isDone }.count }

    @State var showModal = false
    @State var selectedTab = "Home"
    @State private var successKind: SuccessKind?

    var body: some View {
        NavigationStack {
            ZStack {
                HiveBackground()

                if selectedTab == "Pet" {
                    PetRoomView()
                        .padding(.top, 8)
                } else {
                ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    Text("Home")
                        .font(.system(size: 22, weight: .bold))

                    HStack(spacing: 16) {
                        NavigationLink {
                            HariIniView()
                        } label: {
                            MenuCard(title: "Today", icon: "calendar.badge",
                                     color: Color(red: 0.93, green: 0.92, blue: 0.89))
                        }
                        NavigationLink {
                            TerjadwalView()
                        } label: {
                            MenuCard(title: "Scheduled", icon: "calendar",
                                     color: Color(red: 0.88, green: 0.91, blue: 0.93))
                        }
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("My Lists")
                            .font(.system(size: 19, weight: .bold))

                        NavigationLink {
                            NotesView()
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "list.bullet")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color(red: 0.25, green: 0.25, blue: 0.27), in: Circle())

                                Text("Notes")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primary)

                                Spacer()

                                Text("\(activeNotesCount)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primary)
                            }
                            .padding(14)
                            .glassCard(cornerRadius: 24, tint: .white.opacity(0.6))
                            .contentShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Today's Progress")
                                .font(.subheadline.weight(.bold))
                            Spacer()
                            Text("\(todayDone)/\(todayTasks.count) done")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                        }
                        ProgressView(value: todayTasks.isEmpty ? 0 : Double(todayDone) / Double(todayTasks.count))
                            .tint(.orange)
                    }
                    .padding(16)
                    .glassCard(cornerRadius: 20, tint: .white.opacity(0.6))

//                    VStack(spacing: 8) {
//                        VStack(spacing: 6) {
//                            Text("Satu langkah setiap hari")
//                                .font(.headline)
//                                .foregroundColor(.primary)
//                            Text("Ruang belajar tenang + Santai sejenak")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 22)
//                        .glassCard(cornerRadius: 32, tint: .white.opacity(0.55))
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 12)
                }
                }

                if successKind != nil {
                    SuccessModalView(kind: $successKind)
                }
            }
            .safeAreaInset(edge: .bottom) {
                FloatingToolbar(selectedTab: $selectedTab) {
                    showModal = true
                }
            }
            .sheet(isPresented: $showModal) {
                AddReminderSheet { title, date, time in
                    let finalDate = date.map { ReminderModel.combine(date: $0, time: time) }
                    let reminder = ReminderModel(title: title,
                                            date: finalDate,
                                            hasTime: time != nil)
                    modelContext.insert(reminder)
                    try? modelContext.save()
                    NotificationManager.schedule(for: reminder)
                    successKind = .task
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                NotificationManager.requestPermission()
            }
        }
    }
}

struct MenuCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color(red: 0.22, green: 0.22, blue: 0.24))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Text(title)
                .font(.system(size: 17, weight: .bold))
        }
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(height: 136)
        .glassCard(cornerRadius: 22, tint: color.opacity(0.65))
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [ReminderModel.self, NoteModel.self], inMemory: true)
}
