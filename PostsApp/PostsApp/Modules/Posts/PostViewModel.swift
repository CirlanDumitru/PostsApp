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

    // MARK: - Published State

    private(set) var state = State()

    // MARK: - Navigation callback (injected by coordinator / parent)

    var onPostSelected: ((Post) -> Void)?

    // MARK: - Init

    init(apiClient: APIClientProtocol = APIClient.shared,
         analytics: AnalyticsServiceProtocol = AnalyticsService.shared) {
        self.apiClient = apiClient
        self.analytics = analytics
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
                    state.posts = posts
                } catch {
                    state.errorMessage = error.localizedDescription
                }
                state.isLoading = false
            }

        case .selectPost(let post):
            // ✅ Analytics: log post_selected with post_id and post_title
            // post_title is NOT PII, so .string() is safe.
            analytics.logEvent(.postSelected, parameters: [
                .postId:    .int(post.id),
                .postTitle: .string(post.title)
            ])
            onPostSelected?(post)
        }
    }
}
