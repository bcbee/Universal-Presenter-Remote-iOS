//
//  DBZ_AppDelegate.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/16/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

import UIKit
import UserNotifications
import AudioToolbox

class DBZ_AppDelegate: UIResponder, UIApplicationDelegate {

    var feedbackGenerator: UINotificationFeedbackGenerator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Push notifications.
        registerForPushNotifications()

        return true
    }

    // MARK: - Push notifications

    private func registerForPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Notification authorization error: \(error)")
            }
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("APNS: notification received: \(userInfo)")
        Task { await PresenterSession.shared.refresh() }
        completionHandler(.newData)

        if DBZ_UPRGlobal.hasTaptic() {
            feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator?.notificationOccurred(.success)
        } else {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("Did register for remote notifications: \(token)")
        Task { @MainActor in PresenterSession.shared.setAPNS(token) }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Fail to register for remote notifications: \(error)")
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        print("Quick Launch Action!")
        DBZ_UPRGlobal.viewToOpen = shortcutItem.type
        completionHandler(true)
    }

    // MARK: - Lifecycle

    func applicationWillEnterForeground(_ application: UIApplication) {
        Task { await PresenterSession.shared.refresh() }
    }
}
