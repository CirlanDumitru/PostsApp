//
//  ContentView.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var coordinator = AppCoordinator()
    @State private var postsViewModel = PostsViewModel()

    var body: some View {
        NavigationStack {
            PostsView(viewModel: postsViewModel)
                .onAppear {
                    postsViewModel.onPostSelected = { post in
                        coordinator.selectedPost = post
                    }
                }
                .navigationDestination(item: $coordinator.selectedPost) { post in
                    PostDetailView(
                        viewModel: PostDetailViewModel(post: post)
                    )
                }
        }
    }
}
