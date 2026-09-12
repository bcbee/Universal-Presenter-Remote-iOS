//
//  WatchRootView.swift
//  Universal Presenter Remote WatchKit App
//
//  Switches between pairing and presenting on the watch.
//

import SwiftUI

struct WatchRootView: View {
    @Environment(PresenterSession.self) private var session

    var body: some View {
        NavigationStack {
            switch session.phase {
            case .pairing:
                WatchPairView()
            case .presenting:
                WatchPresentView()
            }
        }
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
