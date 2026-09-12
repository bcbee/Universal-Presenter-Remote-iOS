//
//  WatchApp.swift
//  Universal Presenter Remote WatchKit App
//
//  SwiftUI entry point for the watchOS app.
//

import SwiftUI

@main
struct WatchApp: App {
    @State private var session = PresenterSession.shared

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environment(session)
        }
    }
}
