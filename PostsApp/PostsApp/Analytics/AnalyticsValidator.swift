import Foundation

struct AnalyticsValidationIssue: Equatable {
    enum Kind: Equatable {
        case eventNameTooLong
        case parameterNameTooLong
        case tooManyParameters
        case stringValueTooLong
        case requiresHashedValue
    }

    let kind: Kind
    let message: String
}

struct AnalyticsValidator {
    // Defaults loosely aligned with common analytics providers (e.g. Firebase).
    struct Limits: Equatable {
        var maxEventNameLength: Int = 40
        var maxParameterNameLength: Int = 40
        var maxParametersPerEvent: Int = 25
        var maxStringValueLength: Int = 100
    }

    var limits = Limits()

    func validate(eventName: String,
                  parameters: [AnalyticsParameter: AnalyticsValue]) -> [AnalyticsValidationIssue] {
        var issues: [AnalyticsValidationIssue] = []

        if eventName.count > limits.maxEventNameLength {
            issues.append(.init(
                kind: .eventNameTooLong,
                message: "Event name '\(eventName)' exceeds \(limits.maxEventNameLength) chars."
            ))
        }

        if parameters.count > limits.maxParametersPerEvent {
            issues.append(.init(
                kind: .tooManyParameters,
                message: "Event '\(eventName)' has \(parameters.count) params (max \(limits.maxParametersPerEvent))."
            ))
        }

        for (key, value) in parameters {
            if key.rawValue.count > limits.maxParameterNameLength {
                issues.append(.init(
                    kind: .parameterNameTooLong,
                    message: "Param name '\(key.rawValue)' exceeds \(limits.maxParameterNameLength) chars."
                ))
            }

            if key.requiresHashedValue, case .string = value {
                issues.append(.init(
                    kind: .requiresHashedValue,
                    message: "Param '\(key.rawValue)' requires `.hashed` or `.omit`, but got `.string`."
                ))
            }

            if case .string(let s) = value, s.count > limits.maxStringValueLength {
                issues.append(.init(
                    kind: .stringValueTooLong,
                    message: "Param '\(key.rawValue)' string exceeds \(limits.maxStringValueLength) chars."
                ))
            }
        }

        return issues
    }
}

