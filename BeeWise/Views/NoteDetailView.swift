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
    var isNew: Bool = false

    private enum Field { case title, body }
    @FocusState private var focus: Field?

    @State private var draftTitle = ""
    @State private var draftBody = ""
    @State private var successKind: SuccessKind?
    @State private var celebrated = false

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
                        TextField("Title", text: $draftTitle, axis: .vertical)
                            .font(.subheadline.weight(.semibold))
                            .focused($focus, equals: .title)
                            .onSubmit { focus = .body }
                            .onChange(of: draftTitle) { _, new in
                                if new.contains("\n") {
                                    draftTitle = new.replacingOccurrences(of: "\n", with: "")
                                    focus = .body
                                } else {
                                    note.title = new
                                }
                            }

                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $draftBody)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .focused($focus, equals: .body)
                                .frame(minHeight: 120)
                                .scrollContentBackground(.hidden)
                                .onChange(of: draftBody) { _, new in
                                    note.body = new
                                }
                            if draftBody.isEmpty {
                                Text("Add Note")
                                    .font(.caption)
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .allowsHitTesting(false)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                        }
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
                    .background(Color.honeyDeep, in: Circle())
                    .shadow(color: Color.honeyDeep.opacity(0.45), radius: 8, y: 4)
            }
            .padding(28)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .overlay {
            if successKind != nil {
                SuccessModalView(kind: $successKind)
            }
        }
        .onAppear {
            draftTitle = note.title
            draftBody = note.body
            focus = note.title.isEmpty ? .title : .body
            if isNew && !celebrated {
                celebrated = true
                successKind = .note
            }
        }
        .onDisappear {
            note.title = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            note.body = draftBody.trimmingCharacters(in: .whitespacesAndNewlines)
            if note.title.isEmpty && note.body.isEmpty {
                modelContext.delete(note)
            }
            try? modelContext.save()
        }
        }
    }
}

#Preview {
    NavigationStack {
        NoteDetailView(note: NoteModel(title: "Database Lecture"))
    }
    .modelContainer(for: [ReminderModel.self, NoteModel.self], inMemory: true)
}
