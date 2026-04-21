//
//  MMReadiness.swift
//  MotivateMe
//
//  10-bar readiness selector. Bars deepen along the peach scale as the
//  value rises. Tap to set, drag to scrub.
//

import SwiftUI

struct MMReadinessBars: View {
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...10

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let count = range.upperBound - range.lowerBound + 1
                let spacing: CGFloat = 4
                let width = max(0, (geo.size.width - spacing * CGFloat(count - 1)) / CGFloat(count))
                HStack(spacing: spacing) {
                    ForEach(0..<count, id: \.self) { i in
                        let n = range.lowerBound + i
                        let active = n <= value
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(active ? activeColor(for: n) : MMColor.surfaceInput)
                            .frame(width: width, height: 28)
                            .onTapGesture { value = n }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            let x = max(0, min(geo.size.width, drag.location.x))
                            let step = (width + spacing)
                            let i = Int(x / step)
                            value = min(range.upperBound, max(range.lowerBound, range.lowerBound + i))
                        }
                )
            }
            .frame(height: 28)

            HStack {
                Text("Wiped")
                Spacer()
                Text("Ready")
            }
            .font(MMFont.caption2)
            .foregroundStyle(MMColor.textTertiary)
        }
    }

    private func activeColor(for n: Int) -> Color {
        // Map 1..10 onto peach scale indices 0..5 (low → high)
        let idx = min(MMColor.peachScale.count - 1, max(0, (n - 1) * (MMColor.peachScale.count - 1) / max(1, range.upperBound - 1)))
        return MMColor.peachScale[idx]
    }
}
