//
//  PresentView.swift
//  Universal Presenter Remote
//
//  The dark presenting screen with activity log and slide controls.
//

import SwiftUI

struct PresentView: View {
    @Environment(PresenterSession.self) private var session

    var body: some View {
        VStack(spacing: 20) {
            header
            activitySection
            mediaButton
            navButtons
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.uprPresentBackground)
        .preferredColorScheme(.dark)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.uprPresentBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.uprConnected)
                    .frame(width: 10, height: 10)
                Text("Connected · Token \(String(session.token))")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Spacer()
        }
    }

    // MARK: - Activity

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ACTIVITY")
                .font(.system(size: 12, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(.secondary)
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(session.activity) { entry in
                        HStack {
                            Text(entry.label)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                            Spacer()
                            Text(entry.date, format: .dateTime.hour().minute().second())
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(Color.uprPresentCard,
                                    in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .frame(maxHeight: 240)
        }
    }

    // MARK: - Controls

    private var mediaButton: some View {
        Button {
            Task { await session.playPauseMedia() }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                Text("Play / pause media")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(Color.uprPresentCard,
                        in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var navButtons: some View {
        HStack(spacing: 16) {
            navButton(title: "Previous", systemImage: "chevron.left", filled: false) {
                await session.previous()
            }
            navButton(title: "Next", systemImage: "chevron.right", filled: true) {
                await session.next()
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func navButton(title: String,
                           systemImage: String,
                           filled: Bool,
                           action: @escaping () async -> Void) -> some View {
        Button {
            Task { await action() }
        } label: {
            VStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .semibold))
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(filled ? Color.uprPrimary : Color.uprPresentCard,
                        in: RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    NavigationStack {
        PresentView()
    }
    .environment(PresenterSession.previewPresenting)
}
