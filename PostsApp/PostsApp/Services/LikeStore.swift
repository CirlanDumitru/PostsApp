import Foundation
import SwiftData

protocol LikeStoreProtocol {
    func isLiked(postId: Int) -> Bool
    func setLiked(_ liked: Bool, postId: Int)
}

final class LikeStore: LikeStoreProtocol {
    static let shared = LikeStore()

    private let container: ModelContainer

    private init(container: ModelContainer? = nil) {
        if let container {
            self.container = container
            return
        }

        do {
            self.container = try ModelContainer(for: LikedPost.self)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }

    func isLiked(postId: Int) -> Bool {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<LikedPost>(
            predicate: #Predicate { $0.postId == postId }
        )
        do {
            return (try context.fetch(descriptor).first?.liked) ?? false
        } catch {
            return false
        }
    }

    func setLiked(_ liked: Bool, postId: Int) {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<LikedPost>(
            predicate: #Predicate { $0.postId == postId }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                existing.liked = liked
                existing.updatedAt = .now
            } else {
                context.insert(LikedPost(postId: postId, liked: liked))
            }
            try context.save()
        } catch {
            // Intentionally ignore persistence failures for a non-critical feature.
        }
    }
}

