//
//  AnalyticsService.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import Foundation

// MARK: - Protocol (enables mocking in tests)

protocol AnalyticsServiceProtocol {
    func log(_ event: AnalyticsEvent)
}

// MARK: - Live Implementation

final class AnalyticsService: AnalyticsServiceProtocol {

    // Singleton for convenience; can be replaced by DI container.
    static let shared: AnalyticsServiceProtocol = AnalyticsService()

    private let destinations: [AnalyticsDestination]
    private let validator: AnalyticsValidator

    init(destinations: [AnalyticsDestination] = [DebugPrintAnalyticsDestination()],
         validator: AnalyticsValidator = AnalyticsValidator()) {
        self.destinations = destinations
        self.validator = validator
    }

    func log(_ event: AnalyticsEvent) {
        #if DEBUG
        let issues = validator.validate(eventName: event.name, parameters: event.parameters)
        if !issues.isEmpty {
            assertionFailure("""
            Analytics validation failed for '\(event.name)':
            \(issues.map(\.message).joined(separator: "\n"))
            """)
        }
        #endif

        let renderedParams = Self.render(parameters: event.parameters)
        for destination in destinations {
            destination.log(eventName: event.name, parameters: renderedParams.isEmpty ? nil : renderedParams)
        }
    }

    static func render(parameters: [AnalyticsParameter: AnalyticsValue]) -> [String: Any] {
        var out: [String: Any] = [:]
        out.reserveCapacity(parameters.count)
        for (key, value) in parameters {
            if let rendered = value.rawValue {
                out[key.rawValue] = rendered
            }
        }
        return out
    }
}

// MARK: - No-op Mock (for SwiftUI Previews / Unit Tests)

final class MockAnalyticsService: AnalyticsServiceProtocol {
    private(set) var loggedEvents: [(event: AnalyticsEvent, rendered: [String: Any])] = []

    func log(_ event: AnalyticsEvent) {
        let rendered = AnalyticsService.render(parameters: event.parameters)
        loggedEvents.append((event, rendered))
        #if DEBUG
        debugPrint("[MockAnalytics] \(event.name) → \(rendered)")
        #endif
    }
}
