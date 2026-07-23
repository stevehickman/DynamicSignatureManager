//
//  Quote.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation

public struct Quote: IdentifiableEntity {

    public let id: UUID

    public var text: String

    public var author: String?

    public var categoryIDs: Set<UUID>

    public var isEnabled: Bool

    public var weight: Double

    public var createdAt: Date

    public var tags: Set<String>

    public var usageCount: Int

    public var lastUsed: Date?
    
    public init(
        id: UUID = UUID(),
        text: String,
        author: String? = nil,
        categoryIDs: Set<UUID> = [],
        tags: Set<String> = [],
        isEnabled: Bool = true,
        weight: Double = 1.0,
        usageCount: Int = 0,
        lastUsed: Date? = nil,
        createdAt: Date = .now
    ) {

        self.id = id
        self.text = text
        self.author = author
        self.categoryIDs = categoryIDs
        self.tags = tags
        self.isEnabled = isEnabled
        self.weight = weight
        self.usageCount = usageCount
        self.lastUsed = lastUsed
        self.createdAt = createdAt
    }
}
