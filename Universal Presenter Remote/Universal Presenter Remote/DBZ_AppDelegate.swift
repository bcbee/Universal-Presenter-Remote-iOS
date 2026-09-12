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

@main
class DBZ_AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var feedbackGenerator: UINotificationFeedbackGenerator?

    private var preferences: [String: Any] = [:]

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // iCloud: register for external key-value store changes.
        let store = NSUbiquitousKeyValueStore.default
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateKVStoreItems(_:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: store)
        store.synchronize()

        let userDefaults = UserDefaults.standard
        var firstTime = false

        if let saved = userDefaults.dictionary(forKey: "preferences") {
            print("Preferences Loaded")
            preferences = saved
        } else {
            print("New Preferences Generated")
            preferences = ["Instructions": "Disabled", "ControlMode": "Swipe"]
            savePreferences()
            firstTime = true
        }

        if preferences["Instructions"] as? String == "Enabled" || firstTime {
            print("Display Instructions")
            showInstructionsPrompt()
        } else {
            print("Instructions Dismissed")
        }

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
        NotificationCenter.default.post(name: Notification.Name("Refresh"), object: nil)
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
        DBZ_ServerCommunication.setupApns(token)
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
        DBZ_ServerCommunication.checkToken()
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    // MARK: - Preferences / iCloud

    @objc private func updateKVStoreItems(_ notification: Notification) {
        print("iCloud Sync!")

        guard let userInfo = notification.userInfo,
              let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return
        }

        guard reasonForChange == NSUbiquitousKeyValueStoreServerChange ||
              reasonForChange == NSUbiquitousKeyValueStoreInitialSyncChange else {
            return
        }

        let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []
        let store = NSUbiquitousKeyValueStore.default
        let userDefaults = UserDefaults.standard

        for key in changedKeys {
            print("Value for key \(key) changed")
            userDefaults.set(store.object(forKey: key), forKey: key)
        }

        preferences = userDefaults.dictionary(forKey: "preferences") ?? [:]
        NotificationCenter.default.post(name: Notification.Name("PreferenceUpdate"), object: nil)
    }

    private func savePreferences() {
        UserDefaults.standard.set(preferences, forKey: "preferences")
        NSUbiquitousKeyValueStore.default.set(preferences, forKey: "preferences")
    }

    private func resetDefaults() {
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys {
            defaults.removeObject(forKey: key)
        }
    }

    // MARK: - Instructions prompt

    private func showInstructionsPrompt() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Welcome to Universal Presenter Remote",
                                          message: "Would you like to see setup instructions?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                NotificationCenter.default.post(name: Notification.Name("OpenInstructions"), object: nil)
            })
            self?.window?.rootViewController?.present(alert, animated: true)
        }
    }
}
