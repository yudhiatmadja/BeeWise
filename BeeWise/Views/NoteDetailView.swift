//
//  NoteDetailView.swift
//  BeeWise
//
//  Created by Mac on 04/11/26.
//

import SwiftUI
import SwiftData

struct NoteDetailView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var note: NoteModel

    private enum Field { case title, body }
    @FocusState private var focus: Field?

    var body: some View {
        ZStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.primary)
                            .frame(width: 40, height: 40)
                            .background(.white, in: Circle())
                            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { note.isDone.toggle() }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color(red: 0x52 / 255, green: 0x6B / 255, blue: 0x77 / 255), in: Circle())
                            .opacity(note.isDone ? 1 : 0.4)
                    }
                    .buttonStyle(.plain)
                }

                HStack(alignment: .top, spacing: 12) {

                    Button {
                        withAnimation { note.isDone.toggle() }
                    } label: {
                        Circle()
                            .strokeBorder(.white, lineWidth: 2.5)
                            .background(Circle().fill(note.isDone ? Color.white : .clear))
                            .frame(width: 26, height: 26)
                            .overlay {
                                if note.isDone {
                                    Image(systemName: "checkmark")
                                        .font(.caption2.bold())
                                        .foregroundColor(Color.slate)
                                }
                            }
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Judul", text: $note.title, axis: .vertical)
                            .font(.subheadline.weight(.semibold))
                            .focused($focus, equals: .title)
                            .onSubmit { focus = .body }
                            .onChange(of: note.title) { _, new in
                                if new.contains("\n") {
                                    let cleaned = new.replacingOccurrences(of: "\n", with: "")
                                    DispatchQueue.main.async {
                                        note.title = cleaned
                                        focus = .body
                                    }
                                }
                            }

                        TextField("Tambah Catatan", text: $note.body, axis: .vertical)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .focused($focus, equals: .body)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 76, alignment: .topLeading)
                .background(Color.card, in: RoundedRectangle(cornerRadius: 28))
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .scrollDismissesKeyboard(.interactively)
        .background { HiveBackground() }
        .overlay(alignment: .bottomTrailing) {
            Button {
                focus = .body
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Color(red: 0x52 / 255, green: 0x6B / 255, blue: 0x77 / 255), in: Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            }
            .padding(28)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            focus = note.title.isEmpty ? .title : .body
        }
        .onDisappear {
            let t = note.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let b = note.body.trimmingCharacters(in: .whitespacesAndNewlines)
            if t.isEmpty && b.isEmpty {
                modelContext.delete(note)
            }
            try? modelContext.save()
        }
        }
    }
}

#Preview {
    NavigationStack {
        NoteDetailView(note: NoteModel(title: "Kuliah Matkul Basis Data"))
    }
    .modelContainer(for: [ReminderModel.self, NoteModel.self], inMemory: true)
}
