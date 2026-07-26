import Foundation
import Testing
@testable import DynamicSignatureDomain

/// Deterministic linear congruential generator for repeatable selection tests.
struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

@Suite struct QuoteSelectionEngineTests {

    private let engine = QuoteSelectionEngine()

    @Test func returnsNilForEmptyLibrary() {
        #expect(engine.select(from: []) == nil)
    }

    @Test func skipsDisabledAndZeroWeightQuotes() {
        let disabled = Quote(text: "Disabled", isEnabled: false)
        let zeroWeight = Quote(text: "Zero", weight: 0)
        let valid = Quote(text: "Valid")

        var generator = SeededGenerator(state: 1)
        for _ in 0..<20 {
            let selected = engine.select(
                from: [disabled, zeroWeight, valid],
                avoiding: [],
                using: &generator
            )
            #expect(selected?.id == valid.id)
        }
    }

    @Test func avoidsRecentQuotes() {
        let first = Quote(text: "First")
        let second = Quote(text: "Second")

        var generator = SeededGenerator(state: 42)
        for _ in 0..<20 {
            let selected = engine.select(
                from: [first, second],
                avoiding: [first.id],
                using: &generator
            )
            #expect(selected?.id == second.id)
        }
    }

    @Test func fallsBackToFullPoolWhenAllRecent() {
        let only = Quote(text: "Only")
        var generator = SeededGenerator(state: 7)
        let selected = engine.select(from: [only], avoiding: [only.id], using: &generator)

        #expect(selected?.id == only.id)
    }

    @Test func excludesOutOfSeasonQuotes() {
        let christmas = Quote(text: "Christmas", tags: ["christmas"])
        let evergreen = Quote(text: "Evergreen")

        var generator = SeededGenerator(state: 3)
        for _ in 0..<20 {
            let selected = engine.select(
                from: [christmas, evergreen],
                avoiding: [],
                activeSeasonalTags: ["summer", "july"],
                using: &generator
            )
            #expect(selected?.id == evergreen.id)
        }
    }

    @Test func prefersInSeasonQuotesOverUntaggedOnes() {
        let winter = Quote(text: "Winter", tags: ["winter"])
        let evergreen = Quote(text: "Evergreen")

        var generator = SeededGenerator(state: 11)
        for _ in 0..<20 {
            let selected = engine.select(
                from: [winter, evergreen],
                avoiding: [],
                activeSeasonalTags: ["winter", "december", "christmas"],
                using: &generator
            )
            #expect(selected?.id == winter.id)
        }
    }

    @Test func fallsBackToUntaggedWhenInSeasonQuotesAreRecent() {
        let winter = Quote(text: "Winter", tags: ["winter"])
        let evergreen = Quote(text: "Evergreen")

        var generator = SeededGenerator(state: 5)
        for _ in 0..<20 {
            let selected = engine.select(
                from: [winter, evergreen],
                avoiding: [winter.id],
                activeSeasonalTags: ["winter"],
                using: &generator
            )
            #expect(selected?.id == evergreen.id)
        }
    }

    @Test func ignoresSeasonalityWhenEveryQuoteIsOutOfSeason() {
        let christmas = Quote(text: "Christmas", tags: ["christmas"])
        let halloween = Quote(text: "Halloween", tags: ["halloween"])

        var generator = SeededGenerator(state: 13)
        let selected = engine.select(
            from: [christmas, halloween],
            avoiding: [],
            activeSeasonalTags: ["summer"],
            using: &generator
        )
        #expect(selected != nil)
    }

    @Test func organizationalTagsDoNotRestrictSelection() {
        let tagged = Quote(text: "Tagged", tags: ["stoicism", "work"])

        var generator = SeededGenerator(state: 17)
        let selected = engine.select(
            from: [tagged],
            avoiding: [],
            activeSeasonalTags: ["summer"],
            using: &generator
        )
        #expect(selected?.id == tagged.id)
    }

    @Test func seasonalTagMatchingIsCaseInsensitive() {
        let christmas = Quote(text: "Christmas", tags: ["Christmas"])
        let evergreen = Quote(text: "Evergreen")

        var generator = SeededGenerator(state: 23)
        for _ in 0..<20 {
            let selected = engine.select(
                from: [christmas, evergreen],
                avoiding: [],
                activeSeasonalTags: ["christmas", "winter", "december"],
                using: &generator
            )
            #expect(selected?.id == christmas.id)
        }
    }

    @Test func selectsEveryEnabledQuoteEventually() {
        let quotes = (0..<5).map { Quote(text: "Quote \($0)") }
        var generator = SeededGenerator(state: 99)
        var seen = Set<UUID>()

        for _ in 0..<500 {
            if let quote = engine.select(from: quotes, avoiding: [], using: &generator) {
                seen.insert(quote.id)
            }
        }
        #expect(seen.count == quotes.count)
    }
}
