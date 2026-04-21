//
//  OnboardingView.swift
//  MotivateMe
//
//  Multi-step first-launch wizard. Owns the OnboardingDraft, tracks the
//  current step, renders one step at a time, and commits a UserProfile on
//  finish. The root ContentView re-queries UserProfile after save and
//  routes away from this view automatically — nothing here needs to call
//  a dismiss.
//
//  Morning Light shell: progress dots up top, a back-chevron pill on the
//  left, and a pinned peach pill CTA in a soft fading footer.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ErrorPresenter.self) private var errorPresenter
    @State private var draft = OnboardingDraft()
    @State private var stepIndex: Int = 0

    private let steps: [OnboardingStep] = OnboardingStep.allCases

    var body: some View {
        ZStack {
            MMColor.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .id(stepIndex)
                    .transition(.opacity)

                footerBar
            }
        }
    }

    // MARK: - Top: progress dots + back

    private var topBar: some View {
        HStack(alignment: .center) {
            Group {
                if stepIndex > 0 && !isLastStep {
                    Button {
                        withAnimation(MMMotion.spring(response: 0.32, damping: 0.85)) {
                            stepIndex -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(MMColor.primary)
                            .frame(width: 34, height: 34)
                            .background(
                                Circle().fill(MMColor.surfaceCard)
                            )
                            .mmShadow(.sm)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(width: 34, height: 34)
                }
            }

            Spacer()

            HStack(spacing: 6) {
                ForEach(steps.indices, id: \.self) { i in
                    Capsule(style: .continuous)
                        .fill(dotColor(at: i))
                        .frame(width: i == stepIndex ? 20 : 6, height: 6)
                        .animation(MMMotion.spring(response: 0.32, damping: 0.85), value: stepIndex)
                }
            }

            Spacer()

            Color.clear.frame(width: 34, height: 34)
        }
        .frame(height: 44)
    }

    private func dotColor(at index: Int) -> Color {
        if index == stepIndex { return MMColor.primary }
        if index <  stepIndex { return MMColor.primaryMuted }
        return MMColor.border
    }

    // MARK: - Step content

    @ViewBuilder
    private var stepContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                switch steps[stepIndex] {
                case .welcome:    WelcomeStep()
                case .goals:      GoalsStep(draft: draft)
                case .experience: ExperienceStep(draft: draft)
                case .equipment:  EquipmentStep(draft: draft)
                case .schedule:   ScheduleStep(draft: draft)
                case .units:      UnitsStep(draft: draft)
                case .summary:    SummaryStep(draft: draft)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollContentBackground(.hidden)
    }

    // MARK: - Footer

    private var footerBar: some View {
        VStack(spacing: 10) {
            MMPillButton(
                variant: .primary,
                title: continueLabel
            ) {
                advance()
            }
            .opacity(canAdvance ? 1 : 0.5)
            .allowsHitTesting(canAdvance)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            LinearGradient(
                colors: [MMColor.bg.opacity(0), MMColor.bg],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private var continueLabel: String {
        switch steps[stepIndex] {
        case .welcome: return "Let's begin"
        case .summary: return "Get started"
        default:       return "Continue"
        }
    }

    private func advance() {
        if isLastStep {
            save()
        } else {
            withAnimation(MMMotion.spring(response: 0.32, damping: 0.85)) {
                stepIndex += 1
            }
        }
    }

    private var isLastStep: Bool { stepIndex == steps.count - 1 }

    // Step-specific validation. Most steps always allow continuing because
    // they have sensible defaults; goals is the one hard requirement.
    private var canAdvance: Bool {
        switch steps[stepIndex] {
        case .goals: return !draft.goals.isEmpty
        default:     return true
        }
    }

    private func save() {
        let profile = UserProfile()
        draft.apply(to: profile)
        profile.weeklySchedule = ScheduleGenerator.defaultSchedule(
            splitStyle: profile.splitStyle,
            daysPerWeek: profile.daysPerWeek
        )
        modelContext.insert(profile)
        do {
            try modelContext.save()
        } catch {
            errorPresenter.present(error, context: "Saving your profile")
        }
    }
}

enum OnboardingStep: CaseIterable {
    case welcome, goals, experience, equipment, schedule, units, summary
}

#Preview {
    OnboardingView()
        .modelContainer(for: UserProfile.self, inMemory: true)
        .environment(ErrorPresenter())
}
