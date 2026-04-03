//
//  APIClient.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import Foundation

protocol APIClientProtocol {
    func fetchPosts() async throws -> [Post]
}

final class APIClient: APIClientProtocol {

    static let shared = APIClient()
    private init() {}

    private let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!

    func fetchPosts() async throws -> [Post] {
        let url = baseURL.appendingPathComponent("posts")
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Post].self, from: data)
    }
}

// MARK: - Mock for Previews

final class MockAPIClient: APIClientProtocol {
    func fetchPosts() async throws -> [Post] {
        return (1...10).map {
            Post(id: $0, userId: 1,
                 title: "Sample Post \($0)",
                 body: "This is the body of post number \($0). It contains some placeholder text.")
        }
    }
}
