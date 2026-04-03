//
//  PostView.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import SwiftUI

struct PostsView: View {

    @State var viewModel: PostsViewModel

    var body: some View {
        Group {
            if viewModel.state.isLoading {
                ProgressView(.postsStateLoading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.state.errorMessage {
                errorView(message: error)
            } else {
                postsList
            }
        }
        .navigationTitle(.postsTitle)
        .task {
            viewModel.send(.loadPosts)
        }
    }

    // MARK: - Subviews
    private var postsList: some View {
        List(viewModel.state.posts) { post in
            Button {
                viewModel.send(.selectPost(post))
            } label: {
                PostRowView(post: post)
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button(.postsRetry) {
                viewModel.send(.loadPosts)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Row

private struct PostRowView: View {
    let post: Post

    var body: some View {
        HStack(alignment: .center) { 
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title.capitalized)
                    .font(.headline)
                    .lineLimit(2)
                Text(post.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(.vertical, 4)
            Spacer()
            Image(systemName: post.liked ? "heart.fill" : "heart")
                .foregroundStyle(post.liked ? .red : .secondary)
        }
    }
}
