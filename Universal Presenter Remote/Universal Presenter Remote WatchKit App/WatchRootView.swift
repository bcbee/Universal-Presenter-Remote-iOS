//
//  WatchRootView.swift
//  Universal Presenter Remote WatchKit App
//
//  Hosts the pairing screen and pushes the presenting screen so a native
//  back button appears. Popping (back) ends the session.
//

import SwiftUI

struct WatchRootView: View {
    @Environment(PresenterSession.self) private var session

    var body: some View {
        NavigationStack {
            WatchPairView()
                .navigationDestination(isPresented: presentingBinding) {
                    WatchPresentView()
                }
        }
    }

    /// Drives the push: `true` while presenting. Setting it back to `false`
    /// (via the native back button) ends the session.
    private var presentingBinding: Binding<Bool> {
        Binding(
            get: { session.phase == .presenting },
            set: { isPresenting in
                if !isPresenting { session.endSession() }
            }
        )
    }
}

#Preview("Pairing") {
    WatchRootView()
        .environment(PresenterSession.previewPairing)
}

#Preview("Presenting") {
    WatchRootView()
        .environment(PresenterSession.previewPresenting)
}
