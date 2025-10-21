//
//  PerformanceLogger.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import Foundation
import SwiftUI
import Combine
import os.log

// MARK: - Performance Event

struct PerformanceEvent: Identifiable, Sendable {
    let id: UUID
    let timestamp: Date
    let category: PerformanceCategory
    let name: String
    let duration: TimeInterval?
    let metadata: [String: String]

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        category: PerformanceCategory,
        name: String,
        duration: TimeInterval? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.category = category
        self.name = name
        self.duration = duration
        self.metadata = metadata
    }

    var formattedDuration: String {
        guard let duration = duration else { return "N/A" }
        if duration < 0.001 {
            return String(format: "%.0f μs", duration * 1_000_000)
        } else if duration < 1.0 {
            return String(format: "%.1f ms", duration * 1000)
        } else {
            return String(format: "%.2f s", duration)
        }
    }

    var severityLevel: PerformanceSeverity {
        guard let duration = duration else { return .info }

        switch category {
        case .viewLoad, .viewAppear:
            if duration > 1.0 { return .critical }
            if duration > 0.5 { return .warning }
            if duration > 0.2 { return .info }
            return .success

        case .dataFetch, .apiCall:
            if duration > 5.0 { return .critical }
            if duration > 2.0 { return .warning }
            if duration > 1.0 { return .info }
            return .success

        case .computation:
            if duration > 0.5 { return .critical }
            if duration > 0.2 { return .warning }
            if duration > 0.1 { return .info }
            return .success

        case .rendering:
            if duration > 0.016 { return .warning } // 60fps target
            return .success

        case .custom:
            return .info
        }
    }
}

enum PerformanceCategory: String, Codable, CaseIterable, Sendable {
    case viewLoad = "View Load"
    case viewAppear = "View Appear"
    case dataFetch = "Data Fetch"
    case apiCall = "API Call"
    case computation = "Computation"
    case rendering = "Rendering"
    case custom = "Custom"
}

enum PerformanceSeverity: String, Codable, Sendable {
    case success = "✅"
    case info = "ℹ️"
    case warning = "⚠️"
    case critical = "🔴"

    var color: Color {
        switch self {
        case .success: return .green
        case .info: return .blue
        case .warning: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Performance Metrics

struct PerformanceMetrics: Sendable {
    var totalEvents: Int
    var averageDuration: TimeInterval
    var slowestEvent: PerformanceEvent?
    var fastestEvent: PerformanceEvent?
    var eventsByCategory: [PerformanceCategory: Int]

    static let empty = PerformanceMetrics(
        totalEvents: 0,
        averageDuration: 0,
        slowestEvent: nil,
        fastestEvent: nil,
        eventsByCategory: [:]
    )
}

// MARK: - Performance Timer

final class PerformanceTimer: @unchecked Sendable {
    private let startTime: CFAbsoluteTime
    private let category: PerformanceCategory
    private let name: String
    private let metadata: [String: String]
    private let logger: PerformanceLogger?

    init(
        category: PerformanceCategory,
        name: String,
        metadata: [String: String] = [:],
        logger: PerformanceLogger?
    ) {
        self.startTime = CFAbsoluteTimeGetCurrent()
        self.category = category
        self.name = name
        self.metadata = metadata
        self.logger = logger
    }

    func stop() {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let event = PerformanceEvent(
            category: category,
            name: name,
            duration: duration,
            metadata: metadata
        )

        Task { @MainActor in
            logger?.log(event: event)
        }
    }

    deinit {
        // Auto-stop if not manually stopped
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let event = PerformanceEvent(
            category: category,
            name: name,
            duration: duration,
            metadata: metadata
        )

        Task { @MainActor in
            logger?.log(event: event)
        }
    }
}

// MARK: - Performance Logger Service

@MainActor
final class PerformanceLogger: ObservableObject {

    // MARK: - Singleton

    static let shared = PerformanceLogger()

    // MARK: - Published State

    @Published private(set) var events: [PerformanceEvent] = []
    @Published private(set) var metrics: PerformanceMetrics = .empty
    @Published var isEnabled: Bool = false

    // MARK: - Configuration

    private let maxEventsToStore = 1000
    private let osLog = OSLog(subsystem: "com.timetable.dsw", category: "Performance")

    // MARK: - Initialization

    private init() {
        #if DEBUG
        isEnabled = true
        #endif
    }

    // MARK: - Public Methods

    /// Start timing an operation
    func startTimer(
        category: PerformanceCategory,
        name: String,
        metadata: [String: String] = [:]
    ) -> PerformanceTimer {
        PerformanceTimer(
            category: category,
            name: name,
            metadata: metadata,
            logger: isEnabled ? self : nil
        )
    }

    /// Log an event
    func log(event: PerformanceEvent) {
        guard isEnabled else { return }

        // Add to events array
        events.append(event)

        // Trim if needed
        if events.count > maxEventsToStore {
            events.removeFirst(events.count - maxEventsToStore)
        }

        // Update metrics
        updateMetrics()

        // Log to console/oslog
        logToConsole(event: event)
    }

    /// Log instant event without duration
    func logInstant(
        category: PerformanceCategory,
        name: String,
        metadata: [String: String] = [:]
    ) {
        let event = PerformanceEvent(
            category: category,
            name: name,
            duration: nil,
            metadata: metadata
        )
        log(event: event)
    }

    /// Clear all events
    func clear() {
        events.removeAll()
        metrics = .empty
    }

    /// Export events as JSON string
    func exportJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(events),
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }

        return json
    }

    // MARK: - Private Methods

    private func updateMetrics() {
        let eventsWithDuration = events.compactMap { event -> (PerformanceEvent, TimeInterval)? in
            guard let duration = event.duration else { return nil }
            return (event, duration)
        }

        guard !eventsWithDuration.isEmpty else {
            metrics = .empty
            return
        }

        let totalDuration = eventsWithDuration.reduce(0.0) { $0 + $1.1 }
        let averageDuration = totalDuration / Double(eventsWithDuration.count)

        let slowest = eventsWithDuration.max(by: { $0.1 < $1.1 })?.0
        let fastest = eventsWithDuration.min(by: { $0.1 < $1.1 })?.0

        var categoryCounts: [PerformanceCategory: Int] = [:]
        for event in events {
            categoryCounts[event.category, default: 0] += 1
        }

        metrics = PerformanceMetrics(
            totalEvents: events.count,
            averageDuration: averageDuration,
            slowestEvent: slowest,
            fastestEvent: fastest,
            eventsByCategory: categoryCounts
        )
    }

    private func logToConsole(event: PerformanceEvent) {
        let severity = event.severityLevel
        let durationStr = event.formattedDuration
        let metadataStr = event.metadata.isEmpty ? "" : " | \(event.metadata)"

        let message = "[\(event.category.rawValue)] \(event.name): \(durationStr)\(metadataStr)"

        // Log based on severity
        switch severity {
        case .success:
            os_log(.debug, log: osLog, "%{public}@", message)
        case .info:
            os_log(.info, log: osLog, "%{public}@", message)
        case .warning:
            os_log(.default, log: osLog, "⚠️ %{public}@", message)
        case .critical:
            os_log(.error, log: osLog, "🔴 %{public}@", message)
        }

        #if DEBUG
        print("[\(severity.rawValue) Performance] \(message)")
        #endif
    }
}

// MARK: - SwiftUI View Extensions

extension View {
    /// Measure view appearance time
    func measurePerformance(
        name: String,
        category: PerformanceCategory = .viewAppear,
        metadata: [String: String] = [:]
    ) -> some View {
        self.modifier(
            PerformanceMeasurementModifier(
                name: name,
                category: category,
                metadata: metadata
            )
        )
    }
}

private struct PerformanceMeasurementModifier: ViewModifier {
    let name: String
    let category: PerformanceCategory
    let metadata: [String: String]

    @State private var timer: PerformanceTimer?

    func body(content: Content) -> some View {
        content
            .onAppear {
                timer = PerformanceLogger.shared.startTimer(
                    category: category,
                    name: name,
                    metadata: metadata
                )
            }
            .onDisappear {
                timer?.stop()
                timer = nil
            }
    }
}

// MARK: - Environment Key

private struct PerformanceLoggerKey: EnvironmentKey {
    static let defaultValue: PerformanceLogger = .shared
}

extension EnvironmentValues {
    var performanceLogger: PerformanceLogger {
        get { self[PerformanceLoggerKey.self] }
        set { self[PerformanceLoggerKey.self] = newValue }
    }
}
