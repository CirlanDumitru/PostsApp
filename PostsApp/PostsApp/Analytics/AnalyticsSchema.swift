//
//  AnalyticsSchema.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import Foundation
import CommonCrypto

// MARK: - Analytics Events

enum AnalyticsEvent {

    // MARK: Posts Module
    case postSelected
    case postLiked

    // MARK: Screen Navigation 
    case screenView

    // MARK: Internal name
    var name: String {
        switch self {
        case .postSelected:    return "post_selected"
        case .postLiked:       return "post_liked"
        case .screenView:      return "screen_view"
        }
    }
}

// MARK: - Analytics Parameter Keys

enum AnalyticsParameter: String {
    case postId      = "post_id"
    case postTitle   = "post_title"
    case screenName  = "screen_name"
    case feature     = "feature"
    case value       = "value"
}

// MARK: - PII-Safe Value Wrapper

/// Wraps a parameter value and ensures PII is never sent in cleartext.
/// Sensitive fields must use `.hashed(_:)` or `.omit`.
enum AnalyticsValue {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    /// SHA-256 hash of a PII string (e.g. email, name).
    case hashed(String)
    /// Explicitly omit this value from the payload.
    case omit

    var firebaseValue: Any? {
        switch self {
        case .string(let v):  return v
        case .int(let v):     return v
        case .double(let v):  return v
        case .bool(let v):    return v
        case .hashed(let v):  return v.sha256Hash
        case .omit:           return nil
        }
    }
}

// MARK: - String SHA-256 Helper

private extension String {
    var sha256Hash: String {
        var digest = [UInt8](repeating: 0, count: 32)
        let data = Data(self.utf8)
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
