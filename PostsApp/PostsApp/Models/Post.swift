//
//  Post.swift
//  PostsApp
//
//  Created by DimCin on 01.04.2026.
//

import Foundation

struct Post: Identifiable, Hashable, Decodable {
    
    let id: Int
    let userId: Int
    let title: String
    let body: String
    var liked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, userId, title, body
    }
    
    init(id: Int, userId: Int, title: String, body: String, liked: Bool = false) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
        self.liked = liked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        liked = false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
    }
}
