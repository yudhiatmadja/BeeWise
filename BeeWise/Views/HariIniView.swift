//
//  HariIniView.swift
//  BeeWise
//
//  Created by Mac on 05/11/26.
//

import SwiftUI
import SwiftData

struct HariIniView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ReminderModel.createdAt, order: .reverse) private var reminders: [ReminderModel]
    @State private var showAdd = false
    @State private var successKind: SuccessKind?

    private var today: [ReminderModel] {
        reminders.filter { r in
            guard let d = r.date else { return true }
            return Calendar.current.isDateInToday(d)
        }
    }
    private var doneCount: Int { today.filter { $0.isDone }.count }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                Group {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.black)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(doneCount == today.count && !today.isEmpty ? "All Tasks Done" : "One Task Done")
                                .font(.headline)
                            Text("Complete all tasks to earn pet points")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(doneCount) / \(today.count) Done")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.white, in: Capsule())
                    }
                    .padding(16)
                    .glassCard(cornerRadius: 20, tint: .white.opacity(0.55))

                    Text("DAILY SCHEDULE")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    HStack {
                        Text(Date.now, format: .dateTime.weekday(.wide).day().month().year().locale(Locale(identifier: "en")))
                            .font(.title3.bold())
                        Spacer()
                        Label("Today", systemImage: "calendar")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.white, in: Capsule())
                            
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))

                if today.isEmpty {
                    EmptyStateView(
                        title: "No tasks today",
                        subtitle: "Add your first task and get it done today.",
                        buttonTitle: "+ Add Task"
                    ) {
                        showAdd = true
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                } else {
                    ForEach(today, id: \.id) { TaskCardView(reminder: $0) }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background { HiveBackground() }
            .scrollIndicators(.hidden)
            .contentMargins(.bottom, 90)

            Button { showAdd = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.honeyDeep)
                    .clipShape(Circle())
                    .shadow(color: Color.honeyDeep.opacity(0.45), radius: 8, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)

            if successKind != nil {
                SuccessModalView(kind: $successKind)
            }
        }
        .background { HiveBackground() }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showAdd) {
            AddReminderSheet { title, date, time in
                let finalDate = date.map { ReminderModel.combine(date: $0, time: time) }
                let reminder = ReminderModel(title: title, date: finalDate, hasTime: time != nil)
                modelContext.insert(reminder)
                try? modelContext.save()
                NotificationManager.schedule(for: reminder)
                successKind = .task
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationStack { HariIniView() }
        .modelContainer(for: [ReminderModel.self, NoteModel.self], inMemory: true)
}
