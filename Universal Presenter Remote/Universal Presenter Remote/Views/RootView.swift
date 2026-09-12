//
//  RootView.swift
//  Universal Presenter Remote
//
//  Hosts the pairing screen and pushes the presenting screen so a native
//  back button appears. Popping (back) ends the session.
//

import SwiftUI

struct RootView: View {
    @Environment(PresenterSession.self) private var session

    var body: some View {
        NavigationStack {
            PairView()
                .navigationDestination(isPresented: presentingBinding) {
                    PresentView()
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

// MARK: - Launch splash

/// A brief branded splash shown over the app at launch, then faded away.
///
/// The system launch screen (configured in Info.plist) shows the same
/// background color, so the hand-off into this view is seamless. Unlike the
/// system launch screen — which can only stretch an image to fill the screen —
/// this renders the logo at its correct aspect ratio, centered.
struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            Image("UPR")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
        }
        .accessibilityHidden(true)
    }
}

private struct LaunchSplashModifier: ViewModifier {
    @State private var finished = false

    func body(content: Content) -> some View {
        content
            .overlay {
                if !finished {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(0.7))
                withAnimation(.easeOut(duration: 0.35)) {
                    finished = true
                }
            }
    }
}

extension View {
    /// Overlays a branded launch splash that fades out shortly after launch.
    func launchSplash() -> some View {
        modifier(LaunchSplashModifier())
    }
}

#Preview("Pairing") {
    RootView()
        .environment(PresenterSession.previewPairing)
}

#Preview("Presenting") {
    RootView()
        .environment(PresenterSession.previewPresenting)
}
