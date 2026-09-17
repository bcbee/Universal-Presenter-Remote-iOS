//
//  PairView.swift
//  Universal Presenter Remote
//
//  The light "Pair your remote" screen shown while connecting.
//

import StoreKit
import SwiftUI

struct PairView: View {
    @Environment(PresenterSession.self) private var session
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.requestReview) private var requestReview
    @State private var showingInstructions = false

    /// The build number we last asked for a review on. Zero until we've asked,
    /// which reads as "never asked" against any reset build.
    @AppStorage("lastReviewRequestBuild") private var lastReviewRequestBuild = 0

    /// The build that shipped our most recent App Store rating reset. Anyone
    /// last asked before this build is eligible again, so bump this to the
    /// build carrying the reset whenever we clear the rating.
    private static let ratingsResetBuild = 30

    /// This build's number, from `CFBundleVersion`. Falls back to
    /// ``ratingsResetBuild`` so an unreadable build number still records the
    /// ask as having happened since the reset, rather than asking every time.
    private static let currentBuild = Int(
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    ) ?? ratingsResetBuild

    /// Breathing room after the presenting screen pops, so the prompt reads as
    /// part of the home screen rather than landing mid-animation.
    private static let reviewPromptDelay: Duration = .seconds(1)

    /// Minimum available width required to lay the logo/text and token
    /// columns side by side. Chosen to sit between 11" iPad portrait
    /// (stacked) and 13" iPad portrait (side by side).
    private static let sideBySideMinWidth: CGFloat = 950

    /// Max width shared by the logo/text column and the token card so
    /// they stay visually aligned.
    private static let contentMaxWidth: CGFloat = 400

    /// Logo size on a short screen, where the token card and Begin button
    /// need most of the height.
    private static let minLogoSize: CGFloat = 115

    /// Logo size used when there is plenty of vertical room.
    private static let maxLogoSize: CGFloat = 220

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
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
                InstructionsView()
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
            .task(id: session.hasEarnedReviewPrompt) {
                await requestReviewAfterSuccessfulPresentation()
            }
    }

    // MARK: - Review

    /// Asks for an App Store review here on the home screen once the presenter
    /// has finished a successful presentation, so the prompt never interrupts
    /// them mid-talk. The session decides what "successful" means.
    private func requestReviewAfterSuccessfulPresentation() async {
        guard session.hasEarnedReviewPrompt else { return }
        guard lastReviewRequestBuild < Self.ratingsResetBuild else {
            session.clearReviewPrompt()
            return
        }

        try? await Task.sleep(for: Self.reviewPromptDelay)
        guard !Task.isCancelled else { return }

        session.clearReviewPrompt()
        lastReviewRequestBuild = Self.currentBuild
        requestReview()
    }

    // MARK: - Adaptive content

    @ViewBuilder
    private var content: some View {
        GeometryReader { proxy in
            if horizontalSizeClass == .regular && proxy.size.width >= Self.sideBySideMinWidth {
                HStack(spacing: 60) {
                    logoAndText(logoSize: Self.maxLogoSize)
                    VStack(spacing: 28) {
                        tokenCard
                        statusAndBegin
                    }
                    .frame(maxWidth: 420)
                }
                .padding(40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Single fixed page: the pieces shrink to fit the available
                // height rather than scrolling.
                VStack(spacing: Self.stackSpacing(forHeight: proxy.size.height)) {
                    logoAndText(logoSize: Self.logoSize(forHeight: proxy.size.height))
                    tokenCard
                    statusAndBegin
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    /// Grows the logo with the space available: `minLogoSize` on a short
    /// screen, easing up to `maxLogoSize` once there is a tall iPhone's
    /// worth of height to spend.
    private static func logoSize(forHeight height: CGFloat) -> CGFloat {
        let shortScreen: CGFloat = 600
        let tallScreen: CGFloat = 850
        let progress = min(1, max(0, (height - shortScreen) / (tallScreen - shortScreen)))
        return minLogoSize + (maxLogoSize - minLogoSize) * progress
    }

    /// Tightens vertical rhythm on shorter screens.
    private static func stackSpacing(forHeight height: CGFloat) -> CGFloat {
        height < 700 ? 16 : 28
    }

    // MARK: - Sections

    private func logoAndText(logoSize: CGFloat) -> some View {
        VStack(spacing: 16) {
            Image("UPR")
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .frame(width: logoSize, height: logoSize)
            Text("UNIVERSAL PRESENTER REMOTE")
                .font(.system(size: 13, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(Color.uprPrimary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text("Pair your remote")
                .font(.uprTitle(34))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text("Enter the token below into the UPR control software on your presenting computer. As soon as it connects, you can begin.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: Self.contentMaxWidth)
    }

    private var tokenCard: some View {
        VStack(spacing: 16) {
            Text("YOUR CONNECTION TOKEN")
                .font(.system(size: 12, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(.secondary)
            TokenBoxesView(digits: session.tokenDigits)
        }
        .padding(24)
        .frame(maxWidth: Self.contentMaxWidth)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 1)
        )
    }

    private var statusAndBegin: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                Circle()
                    .fill(session.isConnected ? Color.uprConnected : Color(.systemGray3))
                    .frame(width: 10, height: 10)
                Text(session.isConnected ? "Control software connected" : "Waiting for control software…")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(session.isConnected ? Color.uprConnected : Color.secondary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            Button("Begin") {
                session.startSession()
            }
            .buttonStyle(PrimaryButtonStyle(enabled: session.isConnected))
            .disabled(!session.isConnected)
        }
        .frame(maxWidth: Self.contentMaxWidth)
    }
}
#Preview("Loading") {
    NavigationStack {
        PairView()
    }
    .environment(PresenterSession.previewLoading)
}

#Preview("Waiting") {
    NavigationStack {
        PairView()
    }
    .environment(PresenterSession.previewPairing)
}

#Preview("Connected") {
    NavigationStack {
        PairView()
    }
    .environment(PresenterSession.previewConnected)
}

