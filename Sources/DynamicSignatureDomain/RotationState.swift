import Foundation

/// Persisted rotation bookkeeping: what is currently in Mail and which
/// quotes were used recently (to avoid repeats).
public struct RotationState: Codable, Equatable, Sendable {
    public var lastRotated: Date?
    public var currentQuoteID: UUID?
    public var recentQuoteIDs: [UUID]

    public init(
        lastRotated: Date? = nil,
        currentQuoteID: UUID? = nil,
        recentQuoteIDs: [UUID] = []
    ) {
        self.lastRotated = lastRotated
        self.currentQuoteID = currentQuoteID
        self.recentQuoteIDs = recentQuoteIDs
    }

    public mutating func record(quoteID: UUID, at date: Date = .now, keepingRecent limit: Int) {
        lastRotated = date
        currentQuoteID = quoteID
        recentQuoteIDs.removeAll { $0 == quoteID }
        recentQuoteIDs.append(quoteID)
        if recentQuoteIDs.count > max(limit, 0) {
            recentQuoteIDs.removeFirst(recentQuoteIDs.count - max(limit, 0))
        }
    }
}
