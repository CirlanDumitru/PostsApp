//
//  PostDetailsView.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import Foundation
import SwiftUI

struct PostDetailView: View {

    @State var viewModel: PostDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text(viewModel.state.post.title.capitalized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                Text(viewModel.state.post.body)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                HStack {
                    Spacer()
                    Button {
                        viewModel.send(.toggleLike)
                    } label: {
                        Label((viewModel.state.isLiked ? .postStateLiked : .postStateLike),
                              systemImage: viewModel.state.isLiked
                              ? "heart.fill"
                              : "heart"
                        )
                        .font(.title3)
                        .foregroundStyle(viewModel.state.isLiked ? .red : .gray)
                        .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.3), value: viewModel.state.isLiked)
                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(.postTitle(viewModel.state.post.id))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.send(.viewAppeared)
        }
    }
}
