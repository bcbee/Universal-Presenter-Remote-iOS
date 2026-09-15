//
//  PairView.swift
//  Universal Presenter Remote
//
//  The light "Pair your remote" screen shown while connecting.
//

import SwiftUI

struct PairView: View {
    @Environment(PresenterSession.self) private var session
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showingInstructions = false

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

