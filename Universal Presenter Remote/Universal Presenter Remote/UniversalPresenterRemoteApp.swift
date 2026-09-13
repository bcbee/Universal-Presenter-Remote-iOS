//
//  UniversalPresenterRemoteApp.swift
//  Universal Presenter Remote
//
//  SwiftUI entry point.
//

import SwiftUI

@main
struct UniversalPresenterRemoteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var session = PresenterSession.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .launchSplash()
                .environment(session)
        }
    }
}
