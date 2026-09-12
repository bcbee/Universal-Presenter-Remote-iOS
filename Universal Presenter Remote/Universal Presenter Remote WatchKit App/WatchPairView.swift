//
//  WatchPairView.swift
//  Universal Presenter Remote WatchKit App
//
//  Compact "Pair your remote" screen for the watch.
//

import SwiftUI

struct WatchPairView: View {
    @Environment(PresenterSession.self) private var session
    @State private var showingInstructions = false

    var body: some View {
        VStack(spacing: 0) {
            Image("UPR")
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .layoutPriority(1)

            if let digits = session.tokenDigits {
                Text(String(digits))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.uprPrimary)
                    .monospacedDigit()
                    .padding(.bottom, 8)
            } else {
                ProgressView()
                    .padding(.vertical, 13)
            }

            Button("Begin") {
                session.startSession()
            }
            .tint(Color.uprPrimary)
            .disabled(!session.isConnected)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 50)
        .padding(.bottom, 6)
        .ignoresSafeArea(edges: [.top, .bottom])
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Task { await session.setupSession() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Refresh token")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingInstructions = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("Instructions")
            }
        }
        .sheet(isPresented: $showingInstructions) {
            WatchInstructionsView()
        }
        .task(id: session.phase) {
            guard session.phase == .pairing, session.shouldAutoRefresh else { return }
            await session.setupSession()
            while !Task.isCancelled && session.phase == .pairing {
                try? await Task.sleep(for: .seconds(2.5))
                guard session.phase == .pairing else { break }
                await session.refresh()
            }
        }
    }
}

#Preview("Loading") {
    NavigationStack {
        WatchPairView()
    }
    .environment(PresenterSession.previewLoading)
}

#Preview("Waiting") {
    NavigationStack {
        WatchPairView()
    }
    .environment(PresenterSession.previewPairing)
}

#Preview("Connected") {
    NavigationStack {
        WatchPairView()
    }
    .environment(PresenterSession.previewConnected)
}
