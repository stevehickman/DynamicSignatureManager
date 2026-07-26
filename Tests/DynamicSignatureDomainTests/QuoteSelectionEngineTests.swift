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
