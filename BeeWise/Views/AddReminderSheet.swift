//
//  AddReminderSheet.swift
//  BeeWise
//
//  Created by Mac on 03/11/26.
//

import SwiftUI

struct AddReminderSheet: View {

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    @State private var text = ""
    @State private var useDate = false
    @State private var useTime = false
    @State private var date = Date()
    @State private var time = Date()

    private let maxChars = 30
    private let cardColor = Color(red: 0.84, green: 0.87, blue: 0.89)

    var onSave: (String, Date?, Date?) -> Void = { _, _, _ in }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("Apa saja yang akan kamu kerjakan?")
                    .font(.headline)
                    .padding(.top, 24)

                noteCard

                toggleRow(title: "Tanggal", icon: "calendar", isOn: $useDate)

                if useDate {
                    DatePicker("",
                               selection: $date,
                               in: Calendar.current.startOfDay(for: .now)...,
                               displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding(8)
                        .background(Color(white: 0.98), in: RoundedRectangle(cornerRadius: 16))
                        .transition(.opacity.combined(with: .move(edge: .top)))

                    toggleRow(title: "Waktu", icon: "clock", isOn: $useTime)
                        .transition(.opacity.combined(with: .move(edge: .top)))

                    if useTime {
                        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        if isPast {
                                Text("Waktu sudah lewat, pilih waktu yang akan datang.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                    }
                }

                VStack(spacing: 14) {
                    actionButton("Konfirmasi", color: .blue.opacity(0.85), disabled: trimmed.isEmpty || isPast) {
                        save()
                    }
                    actionButton("Hapus", color: .red.opacity(0.85), disabled: false) {
                        dismiss()
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .animation(.easeInOut(duration: 0.25), value: useDate)
        .animation(.easeInOut(duration: 0.25), value: useTime)
        .onChange(of: useDate) { _, isOn in
            useTime = isOn
        }
        .onAppear { isFocused = true }
    }


    private var noteCard: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("CATATAN KEGIATAN", systemImage: "doc")
                        .font(.caption.weight(.semibold))
                    Spacer()
                    Text("\(text.count)/\(maxChars)")
                        .font(.caption.weight(.semibold))
                }
                .foregroundColor(.secondary)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .font(.subheadline.weight(.medium))
                        .focused($isFocused)
                        .frame(minHeight: 90)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .onChange(of: text) { _, newValue in
                            if newValue.count > maxChars {
                                text = String(newValue.prefix(maxChars))
                            }
                        }
                    if text.isEmpty {
                        Text("Tulis rencana kegiatanmu disini...")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.gray.opacity(0.7))
                            .allowsHitTesting(false)
                            .padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                           
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
            .background(cardColor, in: RoundedRectangle(cornerRadius: 30))

            Rectangle()
                .fill(Color(red: 0.93, green: 0.92, blue: 0.89))
                .frame(width: 128, height: 24)
                .offset(y: -12)
        }
        .padding(.top, 12)
    }

    private func toggleRow(title: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.footnote.weight(.semibold))
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.green)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
        )
    }

    private func actionButton(_ title: String, color: Color,
                              disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.18), radius: 5, y: 3)
        }
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        guard !trimmed.isEmpty, !isPast else { return }
        onSave(trimmed, useDate ? date : nil, (useDate && useTime) ? time : nil)
        dismiss()
    }
    private var selectedDateTime: Date {
        ReminderModel.combine(date: date, time: useTime ? time : nil)
    }
    private var isPast: Bool {
        guard useDate else { return false }
        if useTime {
            return selectedDateTime < .now
        }
        return false
    }
}

#Preview {
    AddReminderSheet()
}
