//
//  PresenterSession.swift
//  Universal Presenter Remote
//
//  Observable session model shared by the iOS and watchOS apps.
//

import Foundation
import Observation

/// The single source of truth for a presenting session, shared by the app
/// delegate (push callbacks) and the SwiftUI view tree via ``shared``.
///
/// Replaces the historical static `DBZ_ServerCommunication` namespace and its
/// `NotificationCenter`/`Timer` refresh loop with async/await. A `controlMode`
/// of `0` means connecting, `1` waiting for the control software, `2` connected.
@MainActor
@Observable
final class PresenterSession {

    /// Shared instance so push callbacks and the UI operate on the same state.
    static let shared = PresenterSession()

    enum Phase {
        case pairing
        case presenting
    }

    // MARK: - State

    private(set) var tempToken = 0
    private(set) var token = 0
    private(set) var controlMode = 0
    private(set) var phase: Phase = .pairing
    private(set) var activity: [ActivityEntry] = []

    /// Set when a presentation ends having met both review thresholds. The
    /// pairing screen consumes this to ask for an App Store review, so the
    /// prompt lands once the presenter is back on the home screen rather
    /// than interrupting the talk.
    private(set) var hasEarnedReviewPrompt = false

    private var uid = 0
    private var apnsToken = ""
    private var usesPreviewData = false
    /// Bumps whenever pairing identity changes so in-flight polls cannot
    /// overwrite a newer token or uid.
    private var pairingEpoch = 0
    /// When the current presentation began, used to measure whether it ran
    /// long enough to count as successful.
    private var presentingStartedAt: Date?

    /// How long a presentation must run to count as successful.
    private static let successfulPresentationDuration: TimeInterval = 180
    /// How many commands a presentation must carry to count as successful.
    private static let successfulPresentationCommands = 10

    // MARK: - Derived

    /// Whether the control software has connected and presenting can begin.
    var isConnected: Bool { controlMode == 2 }

    /// The six token digits for display, or `nil` while a token is pending.
    var tokenDigits: [Character]? {
        guard tempToken > 10 else { return nil }
        return Array(String(format: "%06d", tempToken))
    }

    var shouldAutoRefresh: Bool { !usesPreviewData }

    // MARK: - Pairing

    /// Begins a fresh pairing session: new long-poll id and a new server token.
    func setupSession() async {
        pairingEpoch += 1
        uid = Int.random(in: 0..<999999)
        tempToken = 10
        controlMode = 0
        await requestNewToken()
    }

    /// Polls the server for the current control mode. Renews the token if the
    /// server has dropped it (control mode `0`).
    func refresh() async {
        guard tempToken > 10 else {
            await requestNewToken()
            return
        }

        let epoch = pairingEpoch
        guard let response = try? await PresenterService.send("TempSession",
                                                              token: tempToken,
                                                              holdFor: true,
                                                              uid: uid,
                                                              deviceToken: true,
                                                              apns: apnsToken,
                                                              target: nil),
              pairingEpoch == epoch,
              let mode = parseServerInt(response) else {
            return
        }

        controlMode = mode
        if controlMode == 0 {
            tempToken = 0
            await requestNewToken()
        }
    }

    /// Requests a new temp token, then checks its control mode once.
    private func requestNewToken() async {
        pairingEpoch += 1
        let epoch = pairingEpoch

        guard let response = try? await PresenterService.send("NewSession",
                                                              token: 0,
                                                              holdFor: false,
                                                              uid: uid,
                                                              deviceToken: false,
                                                              apns: apnsToken,
                                                              target: nil),
              pairingEpoch == epoch,
              let newToken = parseServerInt(response) else {
            return
        }
        tempToken = newToken

        guard tempToken > 10 else { return }

        guard let modeResponse = try? await PresenterService.send("TempSession",
                                                                  token: tempToken,
                                                                  holdFor: true,
                                                                  uid: uid,
                                                                  deviceToken: true,
                                                                  apns: apnsToken,
                                                                  target: nil),
              pairingEpoch == epoch,
              let mode = parseServerInt(modeResponse) else {
            return
        }
        controlMode = mode
    }

    /// Parses a server integer, accepting the trailing whitespace common in HTTP bodies.
    private func parseServerInt(_ raw: String) -> Int? {
        Int(raw.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    // MARK: - Presenting

    /// Promotes the pending temp token to the live session token and begins presenting.
    func startSession() {
        token = tempToken
        presentingStartedAt = Date()
        phase = .presenting
    }

    /// Ends the presenting session and returns to pairing. The pairing view's
    /// task restarts polling and mints a fresh token.
    func endSession() {
        noteReviewEligibility()
        phase = .pairing
        activity.removeAll()
        controlMode = 0
    }

    /// Records whether the presentation just ended was a successful one — long
    /// enough and busy enough to be worth asking about. Each activity entry is
    /// one command sent, so the log doubles as the command count; this must run
    /// before ``endSession()`` clears it.
    private func noteReviewEligibility() {
        guard let startedAt = presentingStartedAt else { return }
        presentingStartedAt = nil

        let duration = Date().timeIntervalSince(startedAt)
        if duration > Self.successfulPresentationDuration,
           activity.count > Self.successfulPresentationCommands {
            hasEarnedReviewPrompt = true
        }
    }

    /// Clears the earned prompt so a review is only asked for once per
    /// qualifying presentation.
    func clearReviewPrompt() {
        hasEarnedReviewPrompt = false
    }

    func next() async { await sendCommand("SlideUp", label: "Next") }
    func previous() async { await sendCommand("SlideDown", label: "Previous") }
    func playPauseMedia() async { await sendCommand("PlayMedia", label: "Play / pause media") }

    private func sendCommand(_ page: String, label: String) async {
        activity.insert(ActivityEntry(label: label, date: Date()), at: 0)
        _ = try? await PresenterService.send(page,
                                             token: token,
                                             holdFor: true,
                                             uid: uid,
                                             deviceToken: false,
                                             apns: apnsToken,
                                             target: nil)
    }

    // MARK: - Push

    /// Stores the APNS device token and refreshes the pairing state.
    func setAPNS(_ deviceToken: String) {
        apnsToken = deviceToken
        Task { await refresh() }
    }
}
extension PresenterSession {
    static var previewLoading: PresenterSession {
        let session = PresenterSession()
        session.usesPreviewData = true
        return session
    }

    static var previewPairing: PresenterSession {
        let session = PresenterSession()
        session.tempToken = 264971
        session.controlMode = 1
        session.usesPreviewData = true
        return session
    }

    static var previewConnected: PresenterSession {
        let session = PresenterSession()
        session.tempToken = 264971
        session.controlMode = 2
        session.usesPreviewData = true
        return session
    }

    static var previewPresenting: PresenterSession {
        let session = previewConnected
        session.startSession()
        session.activity = [
            ActivityEntry(label: "Next", date: Date().addingTimeInterval(-8)),
            ActivityEntry(label: "Play / pause media", date: Date().addingTimeInterval(-21)),
            ActivityEntry(label: "Previous", date: Date().addingTimeInterval(-35))
        ]
        return session
    }
}

