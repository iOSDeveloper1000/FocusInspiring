//
//  AppDelegate.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 16.02.21.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    lazy var rootViewController: RootViewController? = {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return nil }

        return sceneDelegate.rootViewController
    }()

    lazy var displayNoteViewController: DisplayNoteViewController? = {
        guard let tabBarViewControllers = rootViewController?.viewControllers else { return nil }

        return tabBarViewControllers[ViewControllerIdentifier.displayNoteVC] as? DisplayNoteViewController
    }()


    // MARK: - Launch Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Setup parameter values in first app launch
        // @opt-todo USE UserDefaults.standard.register method
        if !(UserDefaults.standard.bool(forKey: UserKey.appLaunchedBefore)) {
            print("App has not launched before")

            UserKey.setupUserDefaults()
        }

        UNUserNotificationCenter.current().delegate = self

        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FocusInspiring")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


// MARK: - UNUserNotificationCenter Delegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    /**
     Handles a notification request when the user taps on a delivered notification.

     Valid for each notification independent of app state (foreground, background or closed).
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let id = response.notification.request.identifier

        // Determine the user action: DefaultAction = user tapped on notification
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {

            // Set tabbar index to DisplayNoteVC
            rootViewController?.selectedIndex = ViewControllerIdentifier.displayNoteVC

            // Do not present overlay after tap on notification
            displayNoteViewController?.presentOverlayViewInitially = false

        } else if response.actionIdentifier != UNNotificationDismissActionIdentifier {
            track("Unknown user action after notification was sent")
        }

        LocalNotificationHandler.shared.removePendingNotification(uuid: id)

        completionHandler()
    }

    /**
     Handles a notification when the app is in foreground.

     Called before delivery to the user.
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let id = notification.request.identifier
        LocalNotificationHandler.shared.removePendingNotification(uuid: id)

        if let displayNoteViewController = displayNoteViewController,
           displayNoteViewController.isViewLoaded {
            // Ensure to update badge counter
            displayNoteViewController.updateStackCount()
        }

        // Possible UNNotificationPresentationOptions in iOS 14: badge, banner, list, sound
        completionHandler([.banner, .list])
    }
}
