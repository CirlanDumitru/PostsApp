//
//  PostViewModel.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import Foundation
import Observation

@Observable
final class PostsViewModel {

    // MARK: - State

    struct State {
        var posts: [Post] = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }

    // MARK: - Actions

    enum Action {
        case loadPosts
        case selectPost(Post)
    }

    // MARK: - Dependencies

    private let apiClient: APIClientProtocol
    private let analytics: AnalyticsServiceProtocol
    private let likeStore: LikeStoreProtocol

    // MARK: - Published State

    private(set) var state = State()

    // MARK: - Navigation callback (injected by coordinator / parent)

    var onPostSelected: ((Post) -> Void)?

    // MARK: - Init

    init(apiClient: APIClientProtocol = APIClient.shared,
         analytics: AnalyticsServiceProtocol = AnalyticsService.shared,
         likeStore: LikeStoreProtocol = LikeStore.shared) {
        self.apiClient = apiClient
        self.analytics = analytics
        self.likeStore = likeStore
    }

    // MARK: - UDF Entry Point

    @MainActor
    func send(_ action: Action) {
        switch action {

        case .loadPosts:
            guard !state.isLoading else { return }
            state.isLoading = true
            state.errorMessage = nil

            Task {
                do {
                    let posts = try await apiClient.fetchPosts()
                    for post in posts {
                        post.liked = likeStore.isLiked(postId: post.id)
                    }
                    state.posts = posts
                } catch {
                    state.errorMessage = error.localizedDescription
                }
                state.isLoading = false
            }

        case .selectPost(let post):
            analytics.log(.postSelected(postId: post.id, postTitle: post.title))
            onPostSelected?(post)
        }
    }
}
