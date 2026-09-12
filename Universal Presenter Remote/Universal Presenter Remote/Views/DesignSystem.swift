//
//  DesignSystem.swift
//  Universal Presenter Remote
//
//  iOS styling helpers for the SwiftUI interface. Colors live in UPRColors.swift.
//

import SwiftUI

extension Font {
    /// Rounded-bold display font approximating the Android title typeface.
    static func uprTitle(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}

/// The filled magenta "Begin" / "Next" call-to-action button.
struct PrimaryButtonStyle: ButtonStyle {
    var enabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(enabled ? Color.uprPrimary : Color(white: 0.6),
                        in: RoundedRectangle(cornerRadius: 16))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
