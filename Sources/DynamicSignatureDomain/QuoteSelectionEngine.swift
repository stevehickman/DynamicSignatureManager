import Foundation

/// Picks the next quote using weighted random selection, avoiding recently
/// used quotes until the pool would otherwise be empty.
public struct QuoteSelectionEngine: Sendable {

    public init() {}

    public func select(from quotes: [Quote], avoiding recentIDs: [UUID] = []) -> Quote? {
        var generator = SystemRandomNumberGenerator()
        return select(from: quotes, avoiding: recentIDs, using: &generator)
    }

    public func select(
        from quotes: [Quote],
        avoiding recentIDs: [UUID],
        using generator: inout some RandomNumberGenerator
    ) -> Quote? {
        let selectable = quotes.filter { $0.isEnabled && $0.weight > 0 }
        guard !selectable.isEmpty else { return nil }

        let fresh = selectable.filter { !recentIDs.contains($0.id) }
        let pool = fresh.isEmpty ? selectable : fresh

        let totalWeight = pool.reduce(0) { $0 + $1.weight }
        let target = Double.random(in: 0..<totalWeight, using: &generator)

        var cumulative = 0.0
        for quote in pool {
            cumulative += quote.weight
            if target < cumulative {
                return quote
            }
        }
        return pool.last
    }
}
