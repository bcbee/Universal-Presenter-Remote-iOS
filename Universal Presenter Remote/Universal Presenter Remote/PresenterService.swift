//
//  PresenterService.swift
//  Universal Presenter Remote
//
//  Async networking layer for the Universal Presenter Remote server.
//

import Foundation
import os

/// Errors thrown by ``PresenterService``.
enum PresenterServiceError: Error {
    /// The endpoint and parameters could not be assembled into a valid URL.
    case invalidURL
    /// The server responded, but the body could not be decoded as text.
    case undecodableResponse
}

/// Talks to the Universal Presenter Remote server.
///
/// The query format intentionally mirrors the historical client so the existing
/// UPR control software keeps working unchanged: the endpoint is a path segment
/// and the query is `?token=…&holdfor={uid}&apnstoken={apns}&target={target}`.
/// `URLComponents` assembles the query, which correctly inserts the leading `?`
/// and percent-encodes values regardless of which parameters are present.
enum PresenterService {

    static let serverAddress = "https://universalpresenterremote.com"

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.dbztech.UniversalPresenterRemote",
        category: "PresenterService"
    )

    /// Sends a request for `page` and returns the response body as text.
    ///
    /// - Parameters:
    ///   - page: The endpoint path segment (e.g. `"TempSession"`, `"SlideUp"`).
    ///   - token: Session/temp token. Sent as `token=` only when greater than `99999`.
    ///   - holdFor: When `true`, sends `holdfor={uid}` (the long-poll identifier).
    ///   - uid: Per-client long-poll identifier.
    ///   - deviceToken: When `true`, sends `apnstoken={apns}`.
    ///   - apns: APNS device token.
    ///   - target: Optional `target=` value.
    /// - Returns: The response body decoded as text.
    /// - Throws: ``PresenterServiceError`` or any `URLSession` transport error.
    static func send(_ page: String,
                     token: Int,
                     holdFor: Bool,
                     uid: Int,
                     deviceToken: Bool,
                     apns: String,
                     target: String?) async throws -> String {

        guard var components = URLComponents(string: serverAddress) else {
            throw PresenterServiceError.invalidURL
        }
        components.path = "/\(page)"

        var queryItems: [URLQueryItem] = []
        if token > 99999 {
            queryItems.append(URLQueryItem(name: "token", value: String(token)))
        }
        if holdFor {
            queryItems.append(URLQueryItem(name: "holdfor", value: String(uid)))
        }
        if deviceToken {
            queryItems.append(URLQueryItem(name: "apnstoken", value: apns))
        }
        if let target {
            queryItems.append(URLQueryItem(name: "target", value: target))
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            throw PresenterServiceError.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let body = String(data: data, encoding: .utf8) else {
                throw PresenterServiceError.undecodableResponse
            }
            return body
        } catch {
            logger.error("Request to \(page, privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
}
