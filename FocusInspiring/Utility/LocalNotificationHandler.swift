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
 let handler = LocalNotificationHandler.shared

 // (Re)Schedule a notification based on an ID system
 handler.convenienceSchedule(
    uuid: UUID,
    body: "Short Reminder",
    dateTime: DateComponents(/*initializers*/))

 // If notification no longer valid
 handler.removePendingNotification(id: UUID)
 ```
*/
class LocalNotificationHandler {

    // MARK: Properties

    static let shared = LocalNotificationHandler()

    var notifications = [Notification]()

    private init() { }


    // MARK: Public API

    /**
     Conveniently schedule a new notification or reschedule an existing notification

     Constructs a notification object from the given arguments and (re)schedules it. Using an existing uuid will overwrite a formerly scheduled notification.
     - Parameter uuid: The UUID to identify a notification.
     - Parameter body: The body string to be used for the notification.
     - Parameter dateTime: DateComponents to use as a trigger condition.
     */
    func convenienceSchedule(uuid: String, body: String, dateTime: DateComponents) {

        let notification = Notification(id: uuid, body: body, dateTime: dateTime)

        addNewNotification(notification)

        schedule()
    }

    /**
     Add a notification to the handler singleton

     A notification with an existing ID will remove the former entry.
    */
    func addNewNotification(_ notification: Notification) {
        notifications = notifications.filter({ $0.id != notification.id })
        notifications.append(notification)
    }

    /**
     Unschedule notification with given ID from pending notification requests

     This also includes added notifcations that have not yet been scheduled.
     A non-existing ID won't have an effect.
     - Parameter uuid: The UUID to identify the notification to be removed.
    */
    func removePendingNotification(uuid: String) {
        /// Remove from unscheduled notifications
        notifications = notifications.filter({ $0.id != uuid })

        /// Remove from pending notification requests
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuid])
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

            /// Content of notification
            let content = UNMutableNotificationContent()
            content.body = notification.body

            /// Configuration of notification
            content.badge = 1 // @todo COMPUTE CORRECT NUMBER
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.dateTime, repeats: false)

            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { (error) in
                guard error == nil else {
                    track("Trying to schedule notification: \(error?.localizedDescription as String?)")
                    return
                }
            }
        }
    }
}
