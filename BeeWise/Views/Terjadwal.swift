//
//  Terjadwal.swift
//  BeeWise
//
//  Created by Mac on 04/11/26.
//

import SwiftUI
import SwiftData
import EventKit

struct AppleEventCardView: View {
    let event: EKEvent

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.blue)
                .frame(width: 4, height: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title ?? "(Tanpa judul)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.85))
                if let start = event.startDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(start, format: .dateTime.day().month().hour().minute())
                            .font(.caption)
                    }
                    .foregroundStyle(.gray)
                }
            }
            Spacer()
            Label(event.calendar.title.isEmpty ? "Kalender" : event.calendar.title,
                  systemImage: "calendar")
                .font(.caption2.bold())
                .foregroundStyle(.blue)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.blue.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassCard(cornerRadius: 18, tint: .white.opacity(0.65))
    }
}

struct TaskCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var reminder: ReminderModel

    @State private var showDeleteConfirm = false
    @State private var showEdit = false

    var body: some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    reminder.isDone.toggle()
                    if reminder.isDone {
                        NotificationManager.cancel(for: reminder)
                    } else {
                        NotificationManager.schedule(for: reminder)
                    }
                }
            } label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 28, height: 28)
                    .scaleEffect(reminder.isDone ? 1 : 0.96)
                    .overlay {
                        if reminder.isDone {
                            Image(systemName: "checkmark")
                                .font(.caption2.bold())
                                .foregroundColor(Color.slate)
                                .transition(.scale(scale: 0.3).combined(with: .opacity))
                        }
                    }
                    .shadow(color: .black.opacity(0.05), radius: 2)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title.isEmpty ? "Tanpa judul" : reminder.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(reminder.isDone ? .gray : .black.opacity(0.85))
                    .overlay(alignment: .leading) {
                        GeometryReader { geo in
                            Rectangle()
                                .fill(.gray)
                                .frame(height: 1.5)
                                .frame(width: reminder.isDone ? geo.size.width : 0, alignment: .leading)
                                .offset(y: geo.size.height / 2 - 0.75)
                                .animation(.easeInOut(duration: 0.35), value: reminder.isDone)
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: reminder.isDone)

                if let date = reminder.date {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(date, format: .dateTime.day().month().hour().minute())
                            .font(.caption)
                    }
                    .foregroundStyle(.gray)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassCard(cornerRadius: 18, tint: Color(red: 0.88, green: 0.91, blue: 0.92).opacity(0.7))
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Hapus", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                showEdit = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.orange)
        }
        .alert("Hapus tugas?", isPresented: $showDeleteConfirm) {
            Button("Batal", role: .cancel) { }
            Button("Hapus", role: .destructive) {
                NotificationManager.cancel(for: reminder)
                // Hapus async: biarkan swipe-actions tertutup dulu,
                // kalau tidak List crash "invalid number of items".
                let ctx = modelContext
                let obj = reminder
                DispatchQueue.main.async {
                    ctx.delete(obj)
                }
            }
        } message: {
            Text("Tugas \"\(reminder.title)\" akan dihapus permanen.")
        }
        .sheet(isPresented: $showEdit) {
            EditReminderView(reminder: reminder)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

extension View {
    func taskRowStyle() -> some View {
        self.listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
    }
}

struct EditReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var reminder: ReminderModel

    @State private var title: String
    @State private var hasDate: Bool
    @State private var date: Date
    @State private var hasTime: Bool
    @State private var time: Date

    init(reminder: ReminderModel) {
        self.reminder = reminder
        _title = State(initialValue: reminder.title)
        _hasDate = State(initialValue: reminder.date != nil)
        _date = State(initialValue: reminder.date ?? .now)
        _hasTime = State(initialValue: reminder.hasTime)
        _time = State(initialValue: reminder.date ?? .now)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Judul tugas", text: $title, axis: .vertical)

                Toggle("Tanggal", isOn: $hasDate)
                if hasDate {
                    DatePicker("Tanggal", selection: $date, displayedComponents: .date)
                    Toggle("Waktu", isOn: $hasTime)
                    if hasTime {
                        DatePicker("Waktu", selection: $time, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Edit Tugas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        reminder.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        reminder.date = hasDate ? ReminderModel.combine(date: date, time: hasTime ? time : nil) : nil
                        reminder.hasTime = hasDate && hasTime
                        NotificationManager.cancel(for: reminder)
                        NotificationManager.schedule(for: reminder)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPastSelection)
                }
            }
        }
    }

    private var isPastSelection: Bool {
        guard hasDate, hasTime else { return false }
        return ReminderModel.combine(date: date, time: time) < .now
    }
}

struct TerjadwalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ReminderModel.createdAt, order: .reverse) private var reminders: [ReminderModel]
    @State private var showAdd = false
    @State private var weekOffset = 0
    @State private var eventManager = EventStoreManager()
    @State private var selectedDay: Date?
    @Namespace private var dayPill

    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2
        return cal
    }

    private func weekDays(offset: Int) -> [Date] {
        let now = Date.now
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        let base = calendar.date(byAdding: .day, value: offset * 7, to: startOfWeek) ?? now
        return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: base) ?? now }
    }

    private var visibleWeek: [Date] { weekDays(offset: weekOffset) }

    private var weekTitle: String {
        guard let first = visibleWeek.first, let last = visibleWeek.last else { return "" }
        // minggu nyebrang bulan (misal 30 Nov – 6 Des): tulis dua-duanya
        if !calendar.isDate(first, equalTo: last, toGranularity: .month) {
            if calendar.isDate(first, equalTo: last, toGranularity: .year) {
                return "\(first.formatted(.dateTime.month(.wide))) – \(last.formatted(.dateTime.month(.wide).year()))"
            }
            return "\(first.formatted(.dateTime.month(.wide).year())) – \(last.formatted(.dateTime.month(.wide).year()))"
        }
        return first.formatted(.dateTime.month(.wide).year())
    }

    private func appleEvents(on day: Date) -> [EKEvent] {
        eventManager.appleEvents.filter { e in
            guard let d = e.startDate else { return false }
            return calendar.isDate(d, inSameDayAs: day)
        }
    }

    private func tasks(on day: Date) -> [ReminderModel] {
        let list = reminders.filter { r in
            guard let d = r.date else { return false }
            return calendar.isDate(d, inSameDayAs: day)
        }
        return list.sorted { !$0.isDone && $1.isDone }
    }

    private var overdue: [ReminderModel] {
        let startToday = calendar.startOfDay(for: .now)
        let list = reminders.filter { r in
            guard let d = r.date else { return false }
            return d < startToday
        }
        return list.sorted { !$0.isDone && $1.isDone }
    }

    private func visibleTasks(on day: Date) -> [ReminderModel] {
        let startToday = calendar.startOfDay(for: .now)
        let list = reminders.filter { r in
            guard let d = r.date else { return false }
            guard calendar.isDate(d, inSameDayAs: day) else { return false }
            return r.isDone || d >= startToday
        }
        return list.sorted { !$0.isDone && $1.isDone }
    }

    /// Hari yang ditampilkan di list: 1 hari kalau ada filter, seminggu kalau tidak.
    private var daysToShow: [Date] {
        if let day = selectedDay { return [day] }
        return visibleWeek
    }

    private func refreshAppleEvents() {
        let start = calendar.startOfDay(for: visibleWeek.first ?? .now)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? .now
        eventManager.fetchEvents(start: start, end: end)
    }

    private func isSelected(_ day: Date) -> Bool {
        guard let selected = selectedDay else { return false }
        return calendar.isDate(selected, inSameDayAs: day)
    }

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

                    Text("Terjadwal")
                        .font(.system(size: 32, weight: .bold))

                    Text(weekTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)

                    TabView(selection: $weekOffset) {
                        ForEach(-52...52, id: \.self) { offset in
                            HStack(spacing: 0) {
                                ForEach(weekDays(offset: offset), id: \.self) { day in
                                    let isToday = calendar.isDateInToday(day)
                                    let selected = isSelected(day)
                                    // satu pil kuning: di hari terpilih kalau filter aktif,
                                    // kalau tidak ya di hari ini. Meluncur pakai matchedGeometryEffect.
                                    let showPill = selected || (isToday && selectedDay == nil)
                                    let highlighted = showPill
                                    let hasLocal = !tasks(on: day).isEmpty
                                    let hasApple = !appleEvents(on: day).isEmpty
                                    let hasTasks = hasLocal || hasApple
                                    Button {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                            selectedDay = selected ? nil : day
                                        }
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(day, format: .dateTime.weekday(.narrow))
                                                .font(.caption2)
                                                .foregroundStyle(highlighted ? .white : .secondary)
                                            Text(day, format: .dateTime.day())
                                                .font(.subheadline.bold())
                                                .foregroundStyle(highlighted ? .white : .primary)
                                            Circle()
                                                .fill(hasTasks ? (highlighted ? .white : Color.slate) : .clear)
                                                .frame(width: 5, height: 5)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background {
                                            if showPill {
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(Color.honey)
                                                    .frame(width: 46, height: 56)
                                                    .matchedGeometryEffect(id: "dayPill", in: dayPill)
                                            } else if isToday {
                                                // hari ini tanpa filter: hanya border kuning, tanpa fill
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.honey, lineWidth: 2)
                                                    .frame(width: 46, height: 56)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .tag(offset)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 76)
                    .glassCard(cornerRadius: 18, tint: .white.opacity(0.5))

                    if reminders.isEmpty {
                        Text("Belum ada jadwal. Tap + untuk menambah.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))

                if !overdue.isEmpty {
                    Text("Lewat Jatuh Tempo")
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 0, trailing: 20))
                    ForEach(overdue, id: \.id) { TaskCardView(reminder: $0) }
                        .taskRowStyle()
                }

                ForEach(daysToShow, id: \.self) { day in
                    let local = visibleTasks(on: day)
                    let apple = appleEvents(on: day)
                    if !local.isEmpty || !apple.isEmpty {
                        Text(day, format: .dateTime.weekday(.wide).day().month(.wide))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.gray)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 0, trailing: 20))
                        ForEach(local, id: \.id) { TaskCardView(reminder: $0) }
                            .taskRowStyle()
                        ForEach(apple, id: \.eventIdentifier) { AppleEventCardView(event: $0) }
                            .taskRowStyle()
                    }
                }

                if overdue.isEmpty && daysToShow.allSatisfy({ visibleTasks(on: $0).isEmpty && appleEvents(on: $0).isEmpty }) {
                    Text(selectedDay == nil ? "Tidak ada tugas minggu ini." : "Tidak ada tugas hari ini.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                    .background(Color(red: 0.35, green: 0.45, blue: 0.50))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .background { HiveBackground() }
        .navigationBarBackButtonHidden(true)
        .task {
            if (try? await eventManager.requestAccess()) == true {
                refreshAppleEvents()
            }
        }
        .onChange(of: weekOffset) {
            selectedDay = nil
            refreshAppleEvents()
        }
        .sheet(isPresented: $showAdd) {
            AddReminderSheet { title, date, time in
                let finalDate = date.map { ReminderModel.combine(date: $0, time: time) }
                let reminder = ReminderModel(title: title, date: finalDate, hasTime: time != nil)
                modelContext.insert(reminder)
                try? modelContext.save()
                NotificationManager.schedule(for: reminder)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationStack { TerjadwalView() }
        .modelContainer(for: [ReminderModel.self, NoteModel.self], inMemory: true)
}
