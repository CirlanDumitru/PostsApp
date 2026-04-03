import XCTest
@testable import PostsApp

final class AnalyticsTests: XCTestCase {

    func testTypedEventMapping_postSelected() {
        let event = AnalyticsEvent.postSelected(postId: 42, postTitle: "hello")

        XCTAssertEqual(event.name, "post_selected")
        XCTAssertEqual(event.parameters[.postId]?.rawValue as? Int, 42)
        XCTAssertEqual(event.parameters[.postTitle]?.rawValue as? String, "hello")
    }

    func testRenderDropsOmitAndHashesHashedValues() {
        let rendered = AnalyticsService.render(parameters: [
            .feature: .string("posts"),
            .value: .omit,
            .postTitle: .hashed("email@example.com")
        ])

        XCTAssertEqual(rendered["feature"] as? String, "posts")
        XCTAssertNil(rendered["value"])

        let hashed = rendered["post_title"] as? String
        XCTAssertNotNil(hashed)
        XCTAssertNotEqual(hashed, "email@example.com")
        XCTAssertEqual(hashed?.count, 64) // sha256 hex string
    }

    func testValidatorDetectsTooManyParameters() {
        var limits = AnalyticsValidator.Limits()
        limits.maxParametersPerEvent = 2
        let validator = AnalyticsValidator(limits: limits)

        let issues = validator.validate(
            eventName: "post_selected",
            parameters: [
                .postId: .int(1),
                .postTitle: .string("t"),
                .screenName: .string("s")
            ]
        )

        XCTAssertTrue(issues.contains { $0.kind == .tooManyParameters })
    }

    func testValidatorDetectsEventNameTooLong() {
        var limits = AnalyticsValidator.Limits()
        limits.maxEventNameLength = 5
        let validator = AnalyticsValidator(limits: limits)

        let issues = validator.validate(eventName: "toolong", parameters: [:])
        XCTAssertTrue(issues.contains { $0.kind == .eventNameTooLong })
    }

    func testValidatorDetectsStringValueTooLong() {
        var limits = AnalyticsValidator.Limits()
        limits.maxStringValueLength = 3
        let validator = AnalyticsValidator(limits: limits)

        let issues = validator.validate(
            eventName: "screen_view",
            parameters: [.screenName: .string("abcd")]
        )
        XCTAssertTrue(issues.contains { $0.kind == .stringValueTooLong })
    }
}

