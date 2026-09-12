//
//  WatchInstructionsView.swift
//  Universal Presenter Remote WatchKit App
//
//  Compact pairing instructions for the watch.
//

import SwiftUI

struct WatchInstructionsView: View {
    @Environment(\.dismiss) private var dismiss

    private let steps: [(title: String, body: String)] = [
        ("Open the control software",
         "Open the UPR control software on your presenting computer and make sure it's online."),
        ("Enter your token",
         "Type the token shown on the watch into the control software and click begin."),
        ("Start presenting",
         "Tap Begin once connected, then use Next, Previous, and Play / pause to control your slides.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 22, height: 22)
                                .background(Color.uprPrimary, in: Circle())
                            Text(step.title)
                                .font(.headline)
                        }
                        Text(step.body)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
            .navigationTitle("Instructions")
        }
    }
}

#Preview {
    WatchInstructionsView()
}
