//
//  NotificationManager.swift
//  BeeWise
//
//  Created by Mac on 05/11/26.
//

import Foundation
import UserNotifications

enum NotificationManager {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func schedule(for reminder: ReminderModel) {
        guard let date = reminder.date, date > .now, !reminder.isDone else { return }
        let center = UNUserNotificationCenter.current()
        let id = reminder.id.uuidString
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let content = makeContent(title: reminder.title)
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    static func cancel(for reminder: ReminderModel) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }

    private static func makeContent(title: String) -> UNMutableNotificationContent {
        let c = UNMutableNotificationContent()
        c.title = "Task time!"
        c.body = title.isEmpty ? "You have a task due now." : title
        c.sound = .default
        return c
    }
}
