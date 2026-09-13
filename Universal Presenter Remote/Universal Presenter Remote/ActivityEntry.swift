//
//  ActivityEntry.swift
//  Universal Presenter Remote
//
//  A single command recorded in the Present screen's activity log.
//

import Foundation

/// One entry in the Present screen's activity log — a command that was sent and when.
struct ActivityEntry: Identifiable {
    let id = UUID()
    let label: String
    let date: Date
}
