//
//  AnalyticsSchema.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import Foundation
import CommonCrypto

// MARK: - Analytics Parameter Keys

enum AnalyticsParameter: String {
    case postId      = "post_id"
    case postTitle   = "post_title"
    case screenName  = "screen_name"
    case feature     = "feature"
    case value       = "value"

    /// If `true`, this parameter must never be sent as cleartext `.string`.
    /// Use `.hashed` or `.omit` instead.
    var requiresHashedValue: Bool { false }
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

    var rawValue: Any? {
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

// MARK: - Analytics Events (typed payloads)

enum AnalyticsEvent {

    // MARK: Posts Module
    case postSelected(postId: Int, postTitle: String)
    case postLiked(postId: Int, postTitle: String)
    case postUniked(postId: Int, postTitle: String)

    // MARK: Screen Navigation
    case screenView(screenName: String)

    var name: String {
        switch self {
        case .postSelected: return "post_selected"
        case .postLiked:    return "post_liked"
        case .postUniked:    return "post_unliked"
        case .screenView:   return "screen_view"
        }
    }

    var parameters: [AnalyticsParameter: AnalyticsValue] {
        switch self {
        case .postSelected(let postId, let postTitle):
            return [
                .postId: .int(postId),
                .postTitle: .string(postTitle)
            ]
            
        case .postLiked(let postId, let postTitle),
                .postUniked(let postId, let postTitle):
            return [
                .postId: .int(postId),
                .postTitle: .string(postTitle)
            ]
            
        case .screenView(let screenName):
            return [
                .screenName: .string(screenName)
            ]
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
