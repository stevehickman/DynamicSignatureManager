import Foundation
import Testing
@testable import DynamicSignatureDomain

@Suite struct RotationStateTests {

    @Test func recordUpdatesCurrentAndRecent() {
        var state = RotationState()
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1_000)

        state.record(quoteID: id, at: date, keepingRecent: 5)

        #expect(state.currentQuoteID == id)
        #expect(state.lastRotated == date)
        #expect(state.recentQuoteIDs == [id])
    }

    @Test func recentListIsTrimmedToLimit() {
        var state = RotationState()
        let ids = (0..<10).map { _ in UUID() }

        for id in ids {
            state.record(quoteID: id, keepingRecent: 3)
        }

        #expect(state.recentQuoteIDs == Array(ids.suffix(3)))
    }

    @Test func reusedQuoteMovesToEndWithoutDuplicating() {
        var state = RotationState()
        let first = UUID()
        let second = UUID()

        state.record(quoteID: first, keepingRecent: 5)
        state.record(quoteID: second, keepingRecent: 5)
        state.record(quoteID: first, keepingRecent: 5)

        #expect(state.recentQuoteIDs == [second, first])
    }
}
