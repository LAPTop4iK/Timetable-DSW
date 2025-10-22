//
//  PerformanceMonitorView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import SwiftUI

struct PerformanceMonitorView: View {
    // MARK: - Properties

    @ObservedObject var logger = PerformanceLogger.shared
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategory: PerformanceCategory?
    @State private var showingExportSheet = false
    @State private var exportedJSON: String = ""

    // MARK: - Body

    var body: some View {
        NavigationView {
            List {
                metricsSection
                categoryFilterSection
                eventsSection
            }
            .navigationTitle(LocalizedString.perfMonitorTitle.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedString.perfMonitorClear.localized) {
                        logger.clear()
                    }
                    .foregroundAppColor(.error, colorScheme: colorScheme)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedString.perfMonitorExport.localized) {
                        if let json = logger.exportJSON() {
                            exportedJSON = json
                            showingExportSheet = true
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedString.debugDone.localized) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                NavigationView {
                    ScrollView {
                        Text(exportedJSON)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                    }
                    .navigationTitle(LocalizedString.perfMonitorExportedEvents.localized)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(LocalizedString.debugDone.localized) {
                                showingExportSheet = false
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var metricsSection: some View {
        Section(LocalizedString.perfMonitorMetrics.localized) {
            HStack {
                Text(LocalizedString.perfMonitorTotalEvents.localized)
                Spacer()
                Text("\(logger.metrics.totalEvents)")
                    .fontWeight(.bold)
            }

            HStack {
                Text(LocalizedString.perfMonitorAverageDuration.localized)
                Spacer()
                Text(formatDuration(logger.metrics.averageDuration))
                    .fontWeight(.bold)
            }

            if let slowest = logger.metrics.slowestEvent {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedString.perfMonitorSlowestEvent.localized)
                        .font(.caption)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    HStack {
                        Text(slowest.name)
                        Spacer()
                        Text(slowest.formattedDuration)
                            .fontWeight(.bold)
                            .foregroundColor(slowest.severityLevel.color)
                    }
                }
            }

            if let fastest = logger.metrics.fastestEvent {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedString.perfMonitorFastestEvent.localized)
                        .font(.caption)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    HStack {
                        Text(fastest.name)
                        Spacer()
                        Text(fastest.formattedDuration)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }

    private var categoryFilterSection: some View {
        Section(LocalizedString.perfMonitorFilterByCategory.localized) {
            Picker(LocalizedString.perfMonitorCategory.localized, selection: $selectedCategory) {
                Text(LocalizedString.perfMonitorAll.localized).tag(nil as PerformanceCategory?)
                ForEach(PerformanceCategory.allCases, id: \.self) { category in
                    HStack {
                        Text(category.rawValue)
                        if let count = logger.metrics.eventsByCategory[category] {
                            Text("(\(count))")
                                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                        }
                    }
                    .tag(category as PerformanceCategory?)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var eventsSection: some View {
        Section("\(LocalizedString.perfMonitorEvents.localized) (\(filteredEvents.count))") {
            if filteredEvents.isEmpty {
                Text(LocalizedString.perfMonitorNoEventsRecorded.localized)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    .italic()
            } else {
                ForEach(filteredEvents.reversed()) { event in
                    EventRow(event: event)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredEvents: [PerformanceEvent] {
        if let category = selectedCategory {
            return logger.events.filter { $0.category == category }
        }
        return logger.events
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        if duration < 0.001 {
            return String(format: "%.0f μs", duration * 1_000_000)
        } else if duration < 1.0 {
            return String(format: "%.1f ms", duration * 1000)
        } else {
            return String(format: "%.2f s", duration)
        }
    }
}

// MARK: - Event Row

private struct EventRow: View {
    let event: PerformanceEvent

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(event.severityLevel.rawValue)
                Text(event.name)
                    .fontWeight(.semibold)
                Spacer()
                if let duration = event.duration {
                    Text(event.formattedDuration)
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(event.severityLevel.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            event.severityLevel.color.opacity(0.15),
                            in: RoundedRectangle(cornerRadius: 4)
                        )
                }
            }

            HStack {
                Text(event.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        AppColor.themeAccent.color(for: colorScheme).opacity(0.15),
                        in: RoundedRectangle(cornerRadius: 4)
                    )

                Text(formatTimestamp(event.timestamp))
                    .font(.caption)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)

                Spacer()
            }

            if !event.metadata.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(event.metadata.keys.sorted()), id: \.self) { key in
                        HStack {
                            Text(key + ":")
                                .font(.caption2)
                                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                            Text(event.metadata[key] ?? "")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
}

