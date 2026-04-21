//
//  MeasurementsView.swift
//  MotivateMe
//
//  Body-weight log + 30-day trend chart. BodyMeasurement already models
//  arbitrary measurement types via a `type` string, but the MVP only
//  exposes weight — the UI filters to `type == "weight"` everywhere so
//  we can layer other types on later without rewiring the list.
//
//  Entry is via a sheet that writes a new BodyMeasurement; deletion is
//  a swipe-action on the list. Unit follows the user's profile so the
//  same number means the same thing across the app.
//

import SwiftUI
import SwiftData
import Charts

struct MeasurementsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ErrorPresenter.self) private var errorPresenter
    @Bindable var profile: UserProfile

    @Query(sort: \BodyMeasurement.date, order: .reverse) private var allMeasurements: [BodyMeasurement]
    @State private var showingEntrySheet: Bool = false

    private var weightMeasurements: [BodyMeasurement] {
        allMeasurements.filter { $0.type == "weight" }
    }

    private var latest: BodyMeasurement? { weightMeasurements.first }

    // Restrict the chart to the last 90 days so the X-axis reads cleanly
    // once the user has months of data.
    private var chartSeries: [BodyMeasurement] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date.distantPast
        return weightMeasurements
            .filter { $0.date >= cutoff }
            .sorted(by: { $0.date < $1.date })
    }

    var body: some View {
        Group {
            if weightMeasurements.isEmpty {
                emptyState
            } else {
                List {
                    headerSection
                    if chartSeries.count >= 2 {
                        chartSection
                    }
                    logSection
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Measurements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEntrySheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingEntrySheet) {
            MeasurementEntrySheet(profile: profile, previous: latest)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "scalemass")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No measurements yet")
                .font(.headline)
            Text("Log your weight to start tracking changes over time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button {
                showingEntrySheet = true
            } label: {
                Text("Log weight")
                    .padding(.horizontal, 20)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var headerSection: some View {
        if let latest {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatted(latest.value, unit: latest.unit))
                        .font(.largeTitle).bold().monospacedDigit()
                    Text("Latest \u{00B7} " + latest.date.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var chartSection: some View {
        Section("Last 90 days") {
            Chart(chartSeries) { m in
                LineMark(
                    x: .value("Date", m.date),
                    y: .value("Weight", m.value)
                )
                .foregroundStyle(Color.accentColor)
                .interpolationMethod(.monotone)

                PointMark(
                    x: .value("Date", m.date),
                    y: .value("Weight", m.value)
                )
                .foregroundStyle(Color.accentColor)
                .symbolSize(28)
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4))
            }
        }
    }

    private var logSection: some View {
        Section("Log") {
            ForEach(weightMeasurements) { m in
                HStack {
                    Text(m.date.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(.subheadline)
                    Spacer()
                    Text(formatted(m.value, unit: m.unit))
                        .font(.subheadline).bold()
                        .monospacedDigit()
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        delete(m)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }

    private func delete(_ measurement: BodyMeasurement) {
        modelContext.delete(measurement)
        do {
            try modelContext.save()
        } catch {
            errorPresenter.present(error, context: "Deleting that measurement")
        }
    }

    private func formatted(_ value: Double, unit: Unit) -> String {
        let number = value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
        let suffix = unit == .pounds ? "lb" : "kg"
        return "\(number) \(suffix)"
    }
}

// MARK: - Entry sheet

private struct MeasurementEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ErrorPresenter.self) private var errorPresenter
    let profile: UserProfile
    let previous: BodyMeasurement?

    @State private var date: Date = Date()
    @State private var value: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("Weight", text: $value)
                            .keyboardType(.decimalPad)
                        Text(profile.preferredUnit == .pounds ? "lb" : "kg")
                            .foregroundStyle(.secondary)
                    }
                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                } footer: {
                    if let previous {
                        Text("Last entry: " + previous.date.formatted(.dateTime.month(.abbreviated).day()) + " \u{00B7} " + formatted(previous.value, unit: previous.unit))
                    }
                }
            }
            .navigationTitle("Log weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .bold()
                        .disabled(parsedValue == nil)
                }
            }
            .onAppear {
                if let previous {
                    value = previous.value.truncatingRemainder(dividingBy: 1) == 0
                        ? String(format: "%.0f", previous.value)
                        : String(format: "%.1f", previous.value)
                }
            }
        }
    }

    private var parsedValue: Double? {
        let normalized = value.replacingOccurrences(of: ",", with: ".")
        guard let parsed = Double(normalized), parsed > 0, parsed < 1500 else { return nil }
        return parsed
    }

    private func save() {
        guard let parsed = parsedValue else { return }
        let measurement = BodyMeasurement()
        measurement.date = date
        measurement.type = "weight"
        measurement.value = parsed
        measurement.unit = profile.preferredUnit
        modelContext.insert(measurement)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorPresenter.present(error, context: "Saving that measurement")
        }
    }

    private func formatted(_ value: Double, unit: Unit) -> String {
        let number = value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
        let suffix = unit == .pounds ? "lb" : "kg"
        return "\(number) \(suffix)"
    }
}
