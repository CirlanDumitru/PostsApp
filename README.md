# PostsApp

## Analytics (internal design + how to add events)

This app uses a small analytics layer that is designed to stay scalable as the number of events grows, while keeping **event names/parameters consistent**, avoiding “stringly-typed” payloads, and making it easy to add new providers later.

### How it works internally

- **Typed events**: `AnalyticsEvent` is an enum with associated values (the event payload). Each case exposes:
  - `name`: the provider-facing event name string (e.g. `post_selected`)
  - `parameters`: a typed dictionary `[AnalyticsParameter: AnalyticsValue]`
- **Rendering**: `AnalyticsService` converts typed parameters into `[String: Any]` using `AnalyticsValue.rawValue`. `.omit` values are dropped.
- **Validation (DEBUG)**: `AnalyticsValidator` checks basic constraints (event name length, param count, overly long strings, etc). In DEBUG it triggers an assertion failure if the payload is invalid.
- **Fan-out destinations**: `AnalyticsService` logs to one or more `AnalyticsDestination`s. Today it uses `DebugPrintAnalyticsDestination`; adding Firebase (or another provider) is done by implementing a new destination without changing any call sites.

### How to implement analytics for any use case

1. **Add/extend an event in `AnalyticsEvent`** (in `PostsApp/Analytics/AnalyticsSchema.swift`):
   - Add a new enum case with associated values that represent the payload.
   - Add its string `name`.
   - Add its `parameters` mapping using `AnalyticsParameter` keys and `AnalyticsValue` values.
2. **Log it from the feature code** via the protocol:

```swift
analytics.log(.screenView(screenName: "settings"))
analytics.log(.postSelected(postId: post.id, postTitle: post.title))
```

3. **Parameter rules**
   - Use `AnalyticsParameter` for all keys (do not use raw strings).
   - Use `AnalyticsValue` for all values:
     - `.string`, `.int`, `.double`, `.bool` for non-sensitive values
     - `.hashed(...)` for sensitive strings
     - `.omit` if a value must not be sent
   - If you introduce a parameter that must never be sent in cleartext, set `requiresHashedValue = true` for that `AnalyticsParameter` case to enforce it (DEBUG).

### Adding a new analytics provider

Implement `AnalyticsDestination` and register it in `AnalyticsService` (e.g. in `AnalyticsService.shared` or via DI). This keeps provider-specific SDK calls out of the shared schema and feature code.
