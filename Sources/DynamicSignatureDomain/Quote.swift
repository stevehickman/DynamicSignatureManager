import Foundation

/// A single entry in the editable quote library.
public struct Quote: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var text: String
    public var author: String?
    public var tags: Set<String>
    public var isEnabled: Bool
    /// Relative likelihood of selection. Quotes with weight <= 0 are never selected.
    public var weight: Double
    public var usageCount: Int
    public var lastUsed: Date?
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        text: String,
        author: String? = nil,
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
        self.tags = tags
        self.isEnabled = isEnabled
        self.weight = weight
        self.usageCount = usageCount
        self.lastUsed = lastUsed
        self.createdAt = createdAt
    }
}
