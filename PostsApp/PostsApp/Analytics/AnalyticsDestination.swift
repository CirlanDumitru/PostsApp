import Foundation

protocol AnalyticsDestination {
    func log(eventName: String, parameters: [String: Any]?)
}

final class DebugPrintAnalyticsDestination: AnalyticsDestination {
    func log(eventName: String, parameters: [String: Any]?) {
        #if DEBUG
        debugPrint("[Analytics] \(eventName) → \(parameters ?? [:])")
        #endif
    }
}

/// Placeholder for a future Firebase integration.
/// Keep provider-specific types out of the shared schema/service.
// final class FirebaseAnalyticsDestination: AnalyticsDestination {
//     func log(eventName: String, parameters: [String: Any]?) {
//         Analytics.logEvent(eventName, parameters: parameters)
//     }
// }

