//
//  ReminderModel.swift
//  BeeWise
//
//  Created by Mac on 03/11/26.
//

import Foundation
import SwiftData

@Model
final class ReminderModel {
    var id: UUID
    var title: String
    var date: Date?
    var hasTime: Bool
    var isDone: Bool
    var createdAt: Date

    init(title: String, date: Date? = nil, hasTime: Bool = false) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.hasTime = hasTime
        self.isDone = false
        self.createdAt = .now
    }
}

extension ReminderModel {
    static func combine(date: Date, time: Date?) -> Date {
        guard let time else {
            return Calendar.current.startOfDay(for: date)
        }
        let cal = Calendar.current
        let t = cal.dateComponents([.hour, .minute], from: time)
        return cal.date(bySettingHour: t.hour ?? 0,
                        minute: t.minute ?? 0,
                        second: 0,
                        of: date) ?? date
    }
}
