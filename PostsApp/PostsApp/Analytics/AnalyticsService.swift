//
//  AnalyticsService.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import Foundation
//import FirebaseAnalytics

// MARK: - Protocol (enables mocking in tests)

protocol AnalyticsServiceProtocol {
    func logEvent(_ event: AnalyticsEvent,
                  parameters: [AnalyticsParameter: AnalyticsValue])
}

// MARK: - Live Implementation

final class AnalyticsService: AnalyticsServiceProtocol {

    // Singleton for convenience; can be replaced by DI container.
    static let shared: AnalyticsServiceProtocol = AnalyticsService()

    private init() {}

    /// Logs a strongly-typed event to Firebase Analytics.
    /// PII values must be wrapped in `.hashed(_:)` or `.omit` at the call site.
    func logEvent(_ event: AnalyticsEvent,
                  parameters: [AnalyticsParameter: AnalyticsValue] = [:]) {

        var firebaseParams: [String: Any] = [:]

        for (key, value) in parameters {
            if let safeValue = value.firebaseValue {
                firebaseParams[key.rawValue] = safeValue
            }
            // .omit values are silently dropped — never reach Firebase
        }

//        Analytics.logEvent(event.name, parameters: firebaseParams.isEmpty ? nil : firebaseParams)

        #if DEBUG
        print("[Analytics] \(event.name) → \(firebaseParams)")
        #endif
    }
}

// MARK: - No-op Mock (for SwiftUI Previews / Unit Tests)

final class MockAnalyticsService: AnalyticsServiceProtocol {
    private(set) var loggedEvents: [(event: AnalyticsEvent, params: [AnalyticsParameter: AnalyticsValue])] = []

    func logEvent(_ event: AnalyticsEvent,
                  parameters: [AnalyticsParameter: AnalyticsValue] = [:]) {
        loggedEvents.append((event, parameters))
        print("[MockAnalytics] \(event.name) → \(parameters)")
    }
}
