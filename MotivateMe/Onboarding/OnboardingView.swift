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

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var draft = OnboardingDraft()
    @State private var stepIndex: Int = 0

    private let steps: [OnboardingStep] = OnboardingStep.allCases

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(stepIndex + 1), total: Double(steps.count))
                    .progressViewStyle(.linear)
                    .padding(.horizontal)
                    .padding(.top, 12)

                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 16)

                navigationBar
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
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

    private var navigationBar: some View {
        HStack {
            if stepIndex > 0 {
                Button("Back") {
                    withAnimation { stepIndex -= 1 }
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            Button(isLastStep ? "Get started" : "Continue") {
                if isLastStep {
                    save()
                } else {
                    withAnimation { stepIndex += 1 }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canAdvance)
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
            // Persistence failure here is rare and the user has no good
            // remedy; log and continue. ContentView's @Query won't update,
            // so the user will see onboarding again on next launch.
            print("OnboardingView: failed to save profile: \(error)")
        }
    }
}

enum OnboardingStep: CaseIterable {
    case welcome, goals, experience, equipment, schedule, units, summary
}

#Preview {
    OnboardingView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
