//
//  WatchPresentView.swift
//  Universal Presenter Remote WatchKit App
//
//  Slide controls for the watch.
//

import SwiftUI
import WatchKit

struct WatchPresentView: View {
    @Environment(PresenterSession.self) private var session

    private let spacing: CGFloat = 6
    private let topInset: CGFloat = 45
    private let bottomInset: CGFloat = 30
    private let playPauseHeight: CGFloat = 38

    var body: some View {
        // watchOS sizes this view to its content rather than the screen, so
        // `maxHeight: .infinity` never expands. Derive the available height
        // from the physical screen and split it between the slide buttons.
        let screenHeight = WKInterfaceDevice.current().screenBounds.height
        let slideHeight = max(
            playPauseHeight,
            screenHeight - topInset - bottomInset - playPauseHeight - spacing
        )

        VStack(spacing: spacing) {
            controlButton("Play / pause", systemImage: "playpause.fill",
                          fill: Color.white.opacity(0.14), height: playPauseHeight) {
                await session.playPauseMedia()
            }

            HStack(spacing: spacing) {
                controlButton("Previous", systemImage: "chevron.left",
                              fill: Color.white.opacity(0.14),
                              height: slideHeight, vertical: true) {
                    await session.previous()
                }

                controlButton("Next", systemImage: "chevron.right",
                              fill: Color.uprPrimary,
                              height: slideHeight, vertical: true) {
                    await session.next()
                }
            }
        }
        .padding(.top, topInset)
        .padding(.bottom, bottomInset)
        .padding(.horizontal, 4)
    }

    /// A control button styled like the system bordered button but with full
    /// control over height, so Play / pause can stay compact while the slide
    /// buttons expand to fill the remaining space. When `vertical` is set the
    /// icon sits above the title, matching the side-by-side iOS layout.
    private func controlButton(_ title: String,
                               systemImage: String,
                               fill: Color,
                               height: CGFloat,
                               vertical: Bool = false,
                               action: @escaping () async -> Void) -> some View {
        Button {
            Task { await action() }
        } label: {
            Group {
                if vertical {
                    VStack(spacing: 6) {
                        Image(systemName: systemImage)
                            .font(.title3)
                        Text(title)
                            .font(.footnote)
                    }
                } else {
                    Label(title, systemImage: systemImage)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(height: height)
        .background(fill, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        Color.clear
            .navigationDestination(isPresented: .constant(true)) {
                WatchPresentView()
                    .environment(PresenterSession.previewPresenting)
            }
    }
}
