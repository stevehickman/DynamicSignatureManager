import Foundation

/// Picks the next quote using weighted random selection, avoiding recently
/// used quotes until the pool would otherwise be empty. When active seasonal
/// tags are supplied, out-of-season quotes are excluded and in-season quotes
/// are preferred over untagged ones.
public struct QuoteSelectionEngine: Sendable {

    public init() {}

    public func select(
        from quotes: [Quote],
        avoiding recentIDs: [UUID] = [],
        activeSeasonalTags: Set<String>? = nil
    ) -> Quote? {
        var generator = SystemRandomNumberGenerator()
        return select(
            from: quotes,
            avoiding: recentIDs,
            activeSeasonalTags: activeSeasonalTags,
            using: &generator
        )
    }

    public func select(
        from quotes: [Quote],
        avoiding recentIDs: [UUID],
        activeSeasonalTags: Set<String>? = nil,
        using generator: inout some RandomNumberGenerator
    ) -> Quote? {
        let selectable = quotes.filter { $0.isEnabled && $0.weight > 0 }
        guard !selectable.isEmpty else { return nil }

        var candidates = selectable
        var inSeason: [Quote] = []
        if let activeTags = activeSeasonalTags {
            candidates = selectable.filter { quote in
                let seasonal = SeasonalTags.seasonalTags(of: quote)
                return seasonal.isEmpty || !seasonal.isDisjoint(with: activeTags)
            }
            // If every quote is tagged for some other time of year, ignore
            // seasonality rather than produce nothing.
            if candidates.isEmpty {
                candidates = selectable
            } else {
                inSeason = candidates.filter { !SeasonalTags.seasonalTags(of: $0).isEmpty }
            }
        }

        let freshInSeason = inSeason.filter { !recentIDs.contains($0.id) }
        let fresh = candidates.filter { !recentIDs.contains($0.id) }
        let pool = !freshInSeason.isEmpty ? freshInSeason : (!fresh.isEmpty ? fresh : candidates)

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
