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

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<6, id: \.self) { index in
                Text(digit(at: index))
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.uprPrimary)
                    .frame(width: boxWidth, height: boxHeight)
                    .background(Color.uprTokenBoxBackground,
                                in: RoundedRectangle(cornerRadius: 12))
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
