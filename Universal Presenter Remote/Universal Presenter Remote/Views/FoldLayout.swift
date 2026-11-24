//
//  FoldLayout.swift
//  Universal Presenter Remote
//
//  Helpers for laying content out around the iPhone Duo's fold so nothing
//  ever sits in the crease.
//

import SwiftUI

/// Where the iPhone Duo's fold crosses a view, and the two panes either side
/// of it, all in the view's local coordinate space.
///
/// The fold is read with `.includeInactive`, so it is reported whenever the
/// inner display is in use — fully open (where it is inactive and has no
/// thickness) as well as partially folded (where it is active and has a
/// thickness). Laying out against it in both states keeps the layout steady
/// as the device opens and closes, and the panes always exclude the crease
/// itself.
struct FoldSplit {
    /// The direction the crease runs.
    enum Orientation {
        /// The crease runs top to bottom, splitting the view into leading
        /// and trailing panes (the inner display held like a book).
        case vertical
        /// The crease runs side to side, splitting the view into top and
        /// bottom panes.
        case horizontal
    }

    let orientation: Orientation
    /// The crease itself. Zero thickness while the device lies flat.
    let crease: CGRect
    /// The leading (vertical crease) or top (horizontal crease) pane.
    let first: CGRect
    /// The trailing (vertical crease) or bottom (horizontal crease) pane.
    let second: CGRect

    /// The bigger of the two panes, for content that can't be split.
    var largerPane: CGRect {
        first.width * first.height >= second.width * second.height ? first : second
    }

    /// Whether both panes are at least `size` big.
    func panesFit(_ size: CGSize) -> Bool {
        [first, second].allSatisfy { $0.width >= size.width && $0.height >= size.height }
    }

    /// The fold crossing `proxy`'s view, or `nil` when there isn't one: on
    /// every device without a fold, on the iPhone Duo's outer display, and
    /// when the window sits entirely to one side of the fold.
    init?(in proxy: GeometryProxy) {
        guard #available(iOS 27.1, *) else { return nil }

        let bounds = CGRect(origin: .zero, size: proxy.size)
        let creases = proxy.reservedRegions(kind: .division, options: .includeInactive)
            .map(\.frame)
        guard let split = creases.lazy.compactMap({ FoldSplit(crease: $0, bounds: bounds) }).first else {
            return nil
        }
        self = split
    }

    /// The split `crease` makes of `bounds`, both in the same coordinate
    /// space, or `nil` when the crease doesn't run through `bounds`.
    init?(crease: CGRect, bounds: CGRect) {
        let isVertical = crease.height >= crease.width
        // A flat fold has zero thickness, which `CGRect.intersects` treats as
        // empty, so test the crease's centre line against the bounds instead.
        let crossesBounds = isVertical
            ? crease.midX > bounds.minX && crease.midX < bounds.maxX
            : crease.midY > bounds.minY && crease.midY < bounds.maxY
        guard crossesBounds else { return nil }

        self.crease = crease
        if isVertical {
            orientation = .vertical
            first = CGRect(x: bounds.minX, y: bounds.minY,
                           width: max(0, crease.minX - bounds.minX), height: bounds.height)
            second = CGRect(x: crease.maxX, y: bounds.minY,
                            width: max(0, bounds.maxX - crease.maxX), height: bounds.height)
        } else {
            orientation = .horizontal
            first = CGRect(x: bounds.minX, y: bounds.minY,
                           width: bounds.width, height: max(0, crease.minY - bounds.minY))
            second = CGRect(x: bounds.minX, y: crease.maxY,
                            width: bounds.width, height: max(0, bounds.maxY - crease.maxY))
        }
    }
}

/// Where a ``FoldAwareLayout`` gets the crease from.
enum FoldCrease {
    /// Read from the layout's own geometry.
    case measured
    /// Already measured by an enclosing view, in the layout's coordinate
    /// space; `nil` when there is none. Use this inside scrolling or paging
    /// containers, where the view moves under the fold and measuring it there
    /// would reflow the layout as it moves.
    case given(CGRect?)
}

/// Lays out `first` and `second` on either side of the iPhone Duo's fold,
/// or `unsplit` across the whole view when no fold crosses it.
///
/// When a fold crosses the view but either pane is smaller than
/// `minimumPaneSize`, `unsplit` is laid out in the larger pane instead, so
/// content is still never drawn in the crease.
///
/// Each closure is handed the size it has to fill, and its content is centred
/// in that space.
struct FoldAwareLayout<Unsplit: View, First: View, Second: View>: View {
    var crease: FoldCrease = .measured
    var minimumPaneSize: CGSize = .zero
    @ViewBuilder var unsplit: (CGSize) -> Unsplit
    /// The leading pane for a vertical crease, the top pane for a horizontal one.
    @ViewBuilder var first: (CGSize) -> First
    /// The trailing pane for a vertical crease, the bottom pane for a horizontal one.
    @ViewBuilder var second: (CGSize) -> Second

    var body: some View {
        GeometryReader { proxy in
            if let fold = resolvedFold(in: proxy) {
                if fold.panesFit(minimumPaneSize) {
                    first(fold.first.size).placed(in: fold.first)
                    second(fold.second.size).placed(in: fold.second)
                } else {
                    unsplit(fold.largerPane.size).placed(in: fold.largerPane)
                }
            } else {
                unsplit(proxy.size).placed(in: CGRect(origin: .zero, size: proxy.size))
            }
        }
    }

    private func resolvedFold(in proxy: GeometryProxy) -> FoldSplit? {
        switch crease {
        case .measured:
            return FoldSplit(in: proxy)
        case .given(let crease):
            return crease.flatMap {
                FoldSplit(crease: $0, bounds: CGRect(origin: .zero, size: proxy.size))
            }
        }
    }
}

extension View {
    /// Sizes the view to exactly `rect` and positions it there, within a
    /// parent whose coordinate space `rect` is in (such as a
    /// `GeometryReader`). Content that overflows `rect` stays centred on it
    /// rather than spilling off one side.
    func placed(in rect: CGRect) -> some View {
        frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}
