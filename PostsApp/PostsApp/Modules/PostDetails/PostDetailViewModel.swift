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

    // MARK: - Published State

    private(set) var state: State

    // MARK: - Init

    init(post: Post,
         analytics: AnalyticsServiceProtocol = AnalyticsService.shared) {
        self.state = State(post: post)
        self.analytics = analytics
    }

    // MARK: - UDF Entry Point

    @MainActor
    func send(_ action: Action) {
        switch action {

        case .viewAppeared:
            // ✅ Analytics: screen_view event on open
            analytics.logEvent(.screenView, parameters: [
                .screenName: .string("post_detail")
            ])

        case .toggleLike:
            state.isLiked.toggle()

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
