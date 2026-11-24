//
//  TokenBoxesView.swift
//  Universal Presenter Remote
//
//  Reusable six-digit connection token display.
//

import SwiftUI

/// Renders the connection token as six light-purple boxes with purple digits.
/// Shows empty boxes while the token is still being fetched.
struct TokenBoxesView: View {
    /// The six token digits, or `nil` while pending.
    let digits: [Character]?

    var boxWidth: CGFloat = 44
    var boxHeight: CGFloat = 52
    var fontSize: CGFloat = 26
    var spacing: CGFloat = 10

    /// The widest the row may be. The boxes, digits and gaps shrink together
    /// to fit when their natural width is wider than this.
    var maxWidth: CGFloat = .infinity

    /// The row's width at full size.
    private var naturalWidth: CGFloat {
        boxWidth * 6 + spacing * 5
    }

    private var scale: CGFloat {
        min(1, max(0, maxWidth) / naturalWidth)
    }

    var body: some View {
        HStack(spacing: spacing * scale) {
            ForEach(0..<6, id: \.self) { index in
                Text(digit(at: index))
                    .font(.system(size: fontSize * scale, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.uprPrimary)
                    .frame(width: boxWidth * scale, height: boxHeight * scale)
                    .background(Color.uprTokenBoxBackground,
                                in: RoundedRectangle(cornerRadius: 12 * scale))
            }
        }
    }

    private func digit(at index: Int) -> String {
        guard let digits, index < digits.count else { return "" }
        return String(digits[index])
    }
}

#Preview {
    TokenBoxesView(digits: Array("264971"))
        .padding()
}
