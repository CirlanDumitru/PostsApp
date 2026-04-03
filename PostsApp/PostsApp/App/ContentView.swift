//
//  ContentView.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        NavigationStack {
            postsView
                .navigationDestination(item: $coordinator.selectedPost) { post in
                    PostDetailView(
                        viewModel: PostDetailViewModel(post: post)
                    )
                }
        }
    }

    private var postsView: some View {
        let vm = PostsViewModel()
        vm.onPostSelected = { post in
            coordinator.selectedPost = post
        }
        return PostsView(viewModel: vm)
    }
}
