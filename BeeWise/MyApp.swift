//
//  MyApp.swift
//  BeeWise
//
//  Created by Mac on 03/11/26.
//

import SwiftUI
import SwiftData

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [ReminderModel.self, NoteModel.self])
    }
}
