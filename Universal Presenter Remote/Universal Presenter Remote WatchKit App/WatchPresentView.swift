//
//  WatchPresentView.swift
//  Universal Presenter Remote WatchKit App
//
//  Slide controls for the watch.
//

import SwiftUI

struct WatchPresentView: View {
    @Environment(PresenterSession.self) private var session

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Button {
                    Task { await session.next() }
                } label: {
                    Label("Next", systemImage: "chevron.right")
                        .frame(maxWidth: .infinity)
                }
                .tint(Color.uprPrimary)

                Button {
                    Task { await session.previous() }
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }

                Button {
                    Task { await session.playPauseMedia() }
                } label: {
                    Label("Play / pause", systemImage: "playpause.fill")
                        .frame(maxWidth: .infinity)
                }

                Button("End session", role: .destructive) {
                    session.endSession()
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    WatchPresentView()
        .environment(PresenterSession.previewPresenting)
}
