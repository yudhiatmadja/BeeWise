//
//  EventStoreManager.swift
//  BeeWise
//
//  Created by Mac on 06/11/26.
//

import Foundation
import EventKit
import Observation

@Observable
class EventStoreManager {
    let store = EKEventStore()
    var appleEvents: [EKEvent] = []
    var accessGranted = false

    func requestAccess() async throws -> Bool {
        let granted = try await store.requestFullAccessToEvents()
        accessGranted = granted
        return granted
    }

    func fetchEvents(start: Date, end: Date) {
        guard accessGranted else { return }
        let predicate = store.predicateForEvents(
            withStart: start,
            end: end,
            calendars: nil
        )
        appleEvents = store.events(matching: predicate).sorted {
            ($0.startDate ?? .now) < ($1.startDate ?? .now)
        }
    }
}
