import Foundation
import SwiftData

@Model
final class LikedPost {
    @Attribute(.unique) var postId: Int
    var liked: Bool
    var updatedAt: Date

    init(postId: Int, liked: Bool, updatedAt: Date = .now) {
        self.postId = postId
        self.liked = liked
        self.updatedAt = updatedAt
    }
}

