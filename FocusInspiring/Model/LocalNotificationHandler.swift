//
//  LocalNotificationHandler.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 29.04.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UserNotifications

/**
 The handler for managing local notifications using UNUserNotificationCenter

 Normal usage is as described in following example:
 ```
 var handler = LocalNotificationHandler.shared
 let note = Notification(
     id: "ID_x",
     title: "Short Reminder",
     datetime: DateComponents(/* initializers */))
 handler.addNewNotification(note)
 handler.schedule()

 // If notification no longer valid
 handler.clearNotification(id: "ID_x")
 ```
 Inspired by https://learnappmaking.com/local-notifications-scheduling-swift/
*/
struct LocalNotificationHandler {

    // MARK: Properties

    static let shared = LocalNotificationHandler()

    var notifications = [Notification]()

    private init() { }


    // MARK: Public API

    /**
     Add a notification to the handler singleton

     A notification with an existing ID will remove the former entry.
    */
    mutating func addNewNotification(_ notification: Notification) {
        notifications = notifications.filter({ $0.id != notification.id })
        notifications.append(notification)
    }

    /**
     Unschedule notification with given ID from pending notification requests

     This also includes added notifcations that have not yet been scheduled.
     A non-existing ID won't have an effect.
    */
    mutating func removePendingNotification(id: String) {
        /// Remove from unscheduled notifications
        notifications = notifications.filter({ $0.id != id })

        /// Remove from pending notification requests
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// List all the scheduled notifications
    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            for notification in notifications {
                print(notification)
            }
        }
    }

    /**
     Schedule all listed notifications if user has authorized

     In case of pending authorization status user will be requested to authorize.
    */
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break
            }
        }
    }


    // MARK: Helper

    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            if granted && error == nil {
                self.scheduleNotifications()
            }
        }
    }

    private func scheduleNotifications() {

        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            //content.subtitle = xy
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)

            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { (error) in
                guard error == nil else { return }

                print("Notification scheduled! --- ID = \(notification.id)")
            }
        }
    }
}
