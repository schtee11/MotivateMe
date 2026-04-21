//
//  MMComponents.swift
//  MotivateMe
//
//  Reusable Morning-Light building blocks: cards, rings, hero, week
//  bars, heatmap, pill button, soft banner. Each is small enough to
//  drop into any screen and tied only to MMColor / MMFont / MMShadow.
//

import SwiftUI

// MARK: - Card surface

enum MMCardTone {
    case surface, primaryTint, secondaryTint, warningTint, errorTint
}

struct MMCard<Content: View>: View {
    var tone: MMCardTone = .surface
    var radius: CGFloat = 20
    var padding: CGFloat = 16
    var shadow: MMShadow? = .sm
    @ViewBuilder var content: () -> Content

    private var fill: Color {
        switch tone {
        case .surface:        return MMColor.surfaceCard
        case .primaryTint:    return MMColor.primaryTint
        case .secondaryTint:  return MMColor.secondaryTint
        case .warningTint:    return MMColor.warningTint
        case .errorTint:      return MMColor.errorTint
        }
    }

    var body: some View {
        let view = content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
            )
        if let shadow {
            view.mmShadow(shadow)
        } else {
            view
        }
    }
}

// MARK: - Pill button

struct MMPillButton: View {
    enum Variant { case primary, secondary, tertiary, destructive, ghost }
    enum Size    { case lg, md, sm }

    var variant: Variant = .primary
    var size: Size = .lg
    var icon: String? = nil
    var fullWidth: Bool = true
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon).font(.system(size: iconSize, weight: .semibold)) }
                Text(title)
            }
            .font(.system(size: fontSize, weight: .semibold, design: .rounded))
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: height)
            .padding(.horizontal, padX)
            .foregroundStyle(fg)
            .background(
                Capsule(style: .continuous).fill(bg)
            )
        }
        .buttonStyle(.plain)
        .mmShadow(variant == .primary || variant == .destructive ? .sm : .xs)
    }

    private var height: CGFloat   { size == .lg ? 52 : size == .md ? 40 : 32 }
    private var fontSize: CGFloat { size == .lg ? 17 : size == .md ? 15 : 13 }
    private var iconSize: CGFloat { size == .lg ? 17 : size == .md ? 15 : 12 }
    private var padX: CGFloat     { size == .lg ? 20 : size == .md ? 16 : 12 }

    private var bg: Color {
        switch variant {
        case .primary:     return MMColor.primary
        case .secondary:   return MMColor.primaryMuted
        case .tertiary:    return Color.clear
        case .destructive: return MMColor.error
        case .ghost:       return MMColor.surfaceInput
        }
    }

    private var fg: Color {
        switch variant {
        case .primary, .destructive: return MMColor.onPrimary
        case .secondary, .tertiary:  return MMColor.primary
        case .ghost:                 return MMColor.textPrimary
        }
    }
}

// MARK: - Progress ring

struct ProgressRing<Content: View>: View {
    var progress: Double
    var size: CGFloat = 56
    var stroke: CGFloat = 5
    var color: Color = MMColor.primary
    var trackColor: Color = MMColor.primaryMuted
    @ViewBuilder var content: () -> Content

    init(progress: Double,
         size: CGFloat = 56,
         stroke: CGFloat = 5,
         color: Color = MMColor.primary,
         trackColor: Color = MMColor.primaryMuted,
         @ViewBuilder content: @escaping () -> Content = { EmptyView() }) {
        self.progress = progress
        self.size = size
        self.stroke = stroke
        self.color = color
        self.trackColor = trackColor
        self.content = content
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: stroke)
            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(color, style: StrokeStyle(lineWidth: stroke, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(MMMotion.spring(response: 0.6, damping: 0.78), value: progress)
            content()
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Streak hero

struct StreakHero: View {
    var days: Int
    var message: String

    @AppStorage("mm.hideStreakNumbers") private var hideStreakNumbers: Bool = false
    @AppStorage("mm.quietMode") private var quietMode: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Sun-arc motif
            Circle()
                .fill(
                    RadialGradient(
                        colors: [MMColor.primary.opacity(0.20), .clear],
                        center: .center, startRadius: 4, endRadius: 110
                    )
                )
                .frame(width: 180, height: 180)
                .offset(x: 50, y: -60)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .lastTextBaseline, spacing: 10) {
                    if hideStreakNumbers {
                        Image(systemName: "flame.fill")
                            .font(MMFont.title1)
                            .foregroundStyle(MMColor.primary)
                    } else {
                        Text("\(days)")
                            .font(MMFont.streakHero)
                            .foregroundStyle(MMColor.primary)
                            .monospacedDigit()
                        Text(days == 1 ? "day" : "days")
                            .font(MMFont.title3)
                            .foregroundStyle(MMColor.textSecondary)
                    }
                }
                .opacity(quietMode ? 0.55 : 1.0)
                Text(message)
                    .font(MMFont.headline)
                    .foregroundStyle(MMColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 26)
            .padding(.horizontal, 22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [MMColor.primaryTint, MMColor.surfaceCard],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .mmShadow(.sm)
    }
}

// MARK: - Week bars

struct MMWeekBars: View {
    /// Seven values 0…1 (Mon → Sun)
    var values: [Double]
    /// Index of the day to highlight (0…6) or nil
    var todayIndex: Int?
    var height: CGFloat = 110

    private static let labels = ["M","T","W","T","F","S","S"]

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(values.indices, id: \.self) { i in
                let v = max(0.04, min(1, values[i]))
                let isToday = todayIndex == i
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isToday ? MMColor.primary : MMColor.primaryMuted)
                                .frame(height: max(6, geo.size.height * v))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                    .frame(height: height)

                    Text(Self.labels[i % 7])
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(isToday ? MMColor.primary : MMColor.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Heatmap

struct MMHeatmap: View {
    /// 0…1 values, length should be `weeks * 7` (column-major: col * 7 + row)
    var values: [Double]
    var weeks: Int = 12
    var cell: CGFloat = 14
    var gap: CGFloat = 4

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: gap) {
                ForEach(0..<weeks, id: \.self) { col in
                    VStack(spacing: gap) {
                        ForEach(0..<7, id: \.self) { row in
                            let i = col * 7 + row
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(color(for: values.indices.contains(i) ? values[i] : 0))
                                .frame(width: cell, height: cell)
                        }
                    }
                }
            }
            HStack {
                Text("\(weeks) weeks ago")
                Spacer()
                Text("Today")
            }
            .font(MMFont.caption2)
            .foregroundStyle(MMColor.textTertiary)
        }
    }

    private func color(for v: Double) -> Color {
        if v <= 0          { return MMColor.separator }
        if v < 0.34        { return MMColor.peachScale[1] }
        if v < 0.67        { return MMColor.peachScale[3] }
        return MMColor.peachScale[4]
    }
}

// MARK: - Streak chip (compact flame pill)

struct MMStreakChip: View {
    var days: Int
    var tone: Color = MMColor.primary
    var background: Color = MMColor.primaryMuted

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 11, weight: .semibold))
            Text("\(days)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(tone)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(Capsule().fill(background))
    }
}

// MARK: - Section label (uppercase eyebrow)

struct MMEyebrow: View {
    var text: String
    var color: Color = MMColor.textTertiary

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .tracking(0.6)
            .foregroundStyle(color)
    }
}

// MARK: - Soft inline banner

struct MMInlineBanner: View {
    var icon: String
    var title: String
    var subtitle: String?
    var tone: MMCardTone = .secondaryTint
    var iconColor: Color = MMColor.secondary
    var action: (() -> Void)?

    var body: some View {
        let inner = HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(tone == .primaryTint ? MMColor.primaryMuted : MMColor.secondaryMuted)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(MMFont.headline)
                    .foregroundStyle(MMColor.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(MMFont.footnote)
                        .foregroundStyle(MMColor.textSecondary)
                }
            }
            Spacer(minLength: 4)
            if action != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MMColor.textTertiary)
            }
        }

        Group {
            if let action {
                Button(action: action) {
                    inner.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                inner
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tone == .primaryTint ? MMColor.primaryTint : MMColor.secondaryTint)
        )
        .mmShadow(.xs)
    }
}

// MARK: - Quote (italic serif)

struct MMQuoteCard: View {
    var icon: String = "leaf"
    var quote: String
    var attribution: String?

    @AppStorage("mm.serifAccents") private var serifAccents: Bool = true

    private var quoteFont: Font {
        serifAccents
            ? MMFont.quote
            : .system(size: 16, weight: .medium)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(MMColor.secondary)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 6) {
                Text("\u{201C}\(quote)\u{201D}")
                    .font(quoteFont)
                    .foregroundStyle(MMColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let attribution {
                    Text(attribution)
                        .font(MMFont.caption1)
                        .foregroundStyle(MMColor.textSecondary)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(MMColor.secondaryTint)
        )
    }
}

// MARK: - Screen background

struct MMScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            MMColor.bg.ignoresSafeArea()
            content
        }
    }
}

extension View {
    func mmScreen() -> some View { modifier(MMScreenBackground()) }
}
