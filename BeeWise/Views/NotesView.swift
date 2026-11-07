//
//  NotesView.swift
//  BeeWise
//
//  Created by Mac on 04/11/26.
//

import SwiftUI
import SwiftData

struct NotesView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \NoteModel.createdAt, order: .reverse) private var notes: [NoteModel]
    @State private var newNote: NoteModel?
    
    var body: some View {
        ZStack{
            HiveBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 26)
                {
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
                        
                        Text("Catatan")
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        Color.clear
                            .frame(width: 40, height: 40)
                    }
                    
                    ForEach(notes) { NoteRow(note: $0) }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .overlay {
                if notes.isEmpty {
                    Text("Tidak ada catatan")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    let note = NoteModel()
                    modelContext.insert(note)
                    try? modelContext.save()
                    newNote = note
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(Color.slate, in: Circle())
                }
                .padding(28)
            }
            .navigationDestination(item: $newNote) { NoteDetailView(note: $0) }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    struct NoteRow: View {
        
        @Environment(\.modelContext) private var modelContext
        @Bindable var note: NoteModel
        
        var body: some View {
            HStack(alignment: .top, spacing: 14) {
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { note.isDone.toggle() }
                } label: {
                    Circle()
                        .fill(.white)
                        .frame(width: 30, height: 30)
                        .overlay {
                            if note.isDone {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundColor(Color.slate)
                            }
                        }
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    NoteDetailView(note: note)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title.isEmpty ? "Tanpa judul" : note.title)
                            .font(.footnote.weight(.semibold))
                            .strikethrough(note.isDone)
                            .multilineTextAlignment(.leading)
                        
                        if !note.body.isEmpty {
                            Text(note.body)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .foregroundColor(note.isDone ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .contextMenu {
                Button(role: .destructive) {
                    modelContext.delete(note)
                } label: {
                    Label("Hapus", systemImage: "trash")
                }
            }
        }
    }
}
    
    #Preview {
        NavigationStack { NotesView() }
            .modelContainer(for: [ReminderModel.self, NoteModel.self], inMemory: true)
    }

