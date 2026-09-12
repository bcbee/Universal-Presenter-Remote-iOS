//
//  PresenterService.swift
//  Universal Presenter Remote
//
//  Async networking layer for the Universal Presenter Remote server.
//

import Foundation

/// Talks to the Universal Presenter Remote server.
///
/// The URL construction here intentionally mirrors the historical client so the
/// existing UPR control software keeps working unchanged: endpoints are path
/// segments and the query string is built as
/// `/{page}?token=…&holdfor={uid}&apnstoken={apns}&target={target}`.
enum PresenterService {

    static let serverAddress = "https://universalpresenterremote.com"

    /// Sends a request for `page` and returns the response body, or `nil` on failure.
    ///
    /// - Parameters:
    ///   - page: The endpoint path segment (e.g. `"TempSession"`, `"SlideUp"`).
    ///   - token: Session/temp token. Sent as `?token=` only when greater than `99999`.
    ///   - holdFor: When `true`, appends `&holdfor={uid}` (the long-poll identifier).
    ///   - uid: Per-client long-poll identifier.
    ///   - deviceToken: When `true`, appends `&apnstoken={apns}`.
    ///   - apns: APNS device token.
    ///   - target: Optional `&target=` value.
    static func send(_ page: String,
                     token: Int,
                     holdFor: Bool,
                     uid: Int,
                     deviceToken: Bool,
                     apns: String,
                     target: String?) async -> String? {

        var urlString = "\(serverAddress)/\(page)"

        if token > 99999 {
            urlString += "?token=\(token)"
        }

        if holdFor {
            urlString += "&holdfor=\(uid)"
        }

        if deviceToken {
            urlString += "&apnstoken=\(apns)"
        }

        if let target {
            urlString += "&target=\(target)"
        }

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .ascii)
        } catch {
            print("Request to \(page) failed: \(error.localizedDescription)")
            return nil
        }
    }
}
