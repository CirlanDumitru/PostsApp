//
//  PostDetailsViewModel.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import SwiftUI
import Observation

@Observable
final class PostDetailViewModel {

    // MARK: - State

    struct State {
        let post: Post
        var isLiked: Bool = false
    }

    // MARK: - Actions

    enum Action {
        case viewAppeared
        case toggleLike
    }

    // MARK: - Dependencies

    private let analytics: AnalyticsServiceProtocol
    private let likeStore: LikeStoreProtocol

    // MARK: - Published State

    private(set) var state: State

    // MARK: - Init

    init(post: Post,
         analytics: AnalyticsServiceProtocol = AnalyticsService.shared,
         likeStore: LikeStoreProtocol = LikeStore.shared) {
        self.likeStore = likeStore
        let liked = likeStore.isLiked(postId: post.id)
        post.liked = liked
        self.state = State(post: post, isLiked: liked)
        self.analytics = analytics
    }

    // MARK: - UDF Entry Point

    @MainActor
    func send(_ action: Action) {
        switch action {

        case .viewAppeared:
            // ✅ Analytics: screen_view event on open
            analytics.logEvent(.screenView, parameters: [
                .screenName: .int(state.post.id)
            ])

        case .toggleLike:
            state.isLiked.toggle()
            state.post.liked = state.isLiked
            likeStore.setLiked(state.isLiked, postId: state.post.id)

            if state.isLiked {
                // ✅ Analytics: post_liked when user taps like
                analytics.logEvent(.postLiked, parameters: [
                    .postId:    .int(state.post.id),
                    .postTitle: .string(state.post.title)
                ])
            }
        }
    }
}
