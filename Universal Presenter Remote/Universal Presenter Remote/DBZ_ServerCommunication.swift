//
//  DBZ_ServerCommunication.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/11/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

import Foundation

/// Handles all communication with the Universal Presenter Remote server.
///
/// This is a stateless namespace exposing class-level (`static`) API. The
/// accessor methods (`token()`, `controlmode()`, ...) intentionally keep the
/// method-call form that the Objective-C class exposed to Swift so that the
/// existing iOS and watchOS call sites continue to work unchanged.
final class DBZ_ServerCommunication {

    // MARK: - State

    private static let serverAddressValue = "https://universalpresenterremote.com"
    private static var uidValue = 10
    private static var temptokenValue = 10
    private static var controlmodeValue = 0
    private static var tokenValue = 0
    private static var serverAvailableValue = false
    private static var enabledValue = false
    private static var setupValue = false
    private static var apnsValue = ""

    // MARK: - Accessors

    static func serverAddress() -> String { serverAddressValue }
    static func uid() -> Int { uidValue }
    static func temptoken() -> Int { temptokenValue }
    static func controlmode() -> Int { controlmodeValue }
    static func token() -> Int { tokenValue }
    static func serverAvailable() -> Bool { serverAvailableValue }
    static func enabled() -> Bool { enabledValue }
    static func setup() -> Bool { setupValue }
    static func apns() -> String { apnsValue }

    // MARK: - Requests

    static func getResponse(_ page: String,
                            withToken requestToken: Int,
                            withHoldfor holdfor: Bool,
                            withDeviceToken devicetoken: Bool,
                            withTarget targetToken: String?) {

        var strURL = "\(serverAddressValue)/\(page)"
        var processRequest = true

        if requestToken > 99999 {
            strURL += "?token=\(requestToken)"
        } else if page != "NewSession" {
            getResponse("NewSession", withToken: 0, withHoldfor: false, withDeviceToken: false, withTarget: nil)
            processRequest = false
        }

        if holdfor {
            strURL += "&holdfor=\(uidValue)"
        }

        if devicetoken {
            strURL += "&apnstoken=\(apnsValue)"
        }

        if let targetToken {
            strURL += "&target=\(targetToken)"
        }

        if processRequest {
            print(strURL)
            DBZ_UniversalNetworking.makeRequest(strURL, page: page) { response in
                processResponse(response)
            }
        }
    }

    private static func processResponse(_ webResponse: NSMutableArray) {
        guard let page = webResponse.firstObject as? String,
              webResponse.count > 1,
              let result = webResponse[1] as? String else {
            return
        }

        switch page {
        case "Alive":
            checkStatusCallback(result)
        case "NewSession":
            newTokenCallback(result)
        case "TempSession":
            checkTokenCallback(result)
        default:
            break
        }
    }

    // MARK: - Session lifecycle

    static func setupUid() {
        uidValue = Int.random(in: 0..<999999)
        temptokenValue = 10
        setupValue = true
    }

    static func checkStatus() {
        getResponse("Alive", withToken: 0, withHoldfor: false, withDeviceToken: false, withTarget: nil)
    }

    static func checkStatusCallback(_ response: String) {
        if response == "Ready" {
            print("Alive!")
            serverAvailableValue = true
        } else {
            print("Dead :(")
            serverAvailableValue = false
            controlmodeValue = 0
            checkStatus()
        }
    }

    static func checkToken() {
        getResponse("TempSession", withToken: temptokenValue, withHoldfor: true, withDeviceToken: true, withTarget: nil)
    }

    static func checkTokenCallback(_ response: String) {
        controlmodeValue = Int(response) ?? 0

        if controlmodeValue == 0 {
            temptokenValue = 0
        }

        if temptokenValue == 0 {
            getResponse("NewSession", withToken: 0, withHoldfor: false, withDeviceToken: false, withTarget: nil)
        }

        updateInterface()
    }

    static func newTokenCallback(_ response: String) {
        temptokenValue = Int(response) ?? 0
        checkToken()
    }

    static func updateInterface() {
        NotificationCenter.default.post(name: Notification.Name("UpdateInterface"), object: nil)
    }

    static func setupApns(_ deviceToken: String) {
        apnsValue = deviceToken
        checkToken()
    }

    static func activateSession(_ targetToken: String) {
        getResponse("StartQR", withToken: temptokenValue, withHoldfor: false, withDeviceToken: false, withTarget: targetToken)
    }

    static func startSession() {
        tokenValue = temptokenValue
        enabledValue = true
    }

    static func endSession() {
        setupUid()
        checkToken()
        enabledValue = false
    }
}
