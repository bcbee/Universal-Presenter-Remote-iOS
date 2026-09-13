//
//  AppDelegate.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/16/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

import UIKit
import UserNotifications
import os

/// Handles push-notification registration and delivery for the iOS app.
///
/// Incoming pushes signal that the server state changed, so each one refreshes
/// the shared ``PresenterSession`` and plays a success haptic.
final class AppDelegate: UIResponder, UIApplicationDelegate {

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.dbztech.UniversalPresenterRemote",
        category: "AppDelegate"
    )

    /// Retained across the async haptic so it isn't deallocated before firing.
    private let feedbackGenerator = UINotificationFeedbackGenerator()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications()
        return true
    }

    // MARK: - Push notifications

    private func registerForPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [logger] granted, error in
            if let error {
                logger.error("Notification authorization error: \(error.localizedDescription, privacy: .public)")
            }
            guard granted else { return }
            Task { @MainActor in
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        logger.debug("Remote notification received")
        Task { @MainActor in
            await PresenterSession.shared.refresh()
            feedbackGenerator.notificationOccurred(.success)
            completionHandler(.newData)
        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        logger.debug("Registered for remote notifications")
        Task { @MainActor in PresenterSession.shared.setAPNS(token) }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.error("Failed to register for remote notifications: \(error.localizedDescription, privacy: .public)")
    }

    // MARK: - Lifecycle

    func applicationWillEnterForeground(_ application: UIApplication) {
        Task { await PresenterSession.shared.refresh() }
    }
}
