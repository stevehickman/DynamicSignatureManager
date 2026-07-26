import Foundation
import Testing
@testable import DynamicSignatureDomain

@Suite struct SeasonalTagsTests {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func date(month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day))!
    }

    @Test func midsummerDayHasSummerAndMonthTags() {
        let tags = SeasonalTags.activeTags(on: date(month: 7, day: 15), calendar: calendar)
        #expect(tags == ["summer", "july"])
    }

    @Test func autumnIncludesFallAlias() {
        let tags = SeasonalTags.activeTags(on: date(month: 9, day: 20), calendar: calendar)
        #expect(tags.contains("autumn"))
        #expect(tags.contains("fall"))
        #expect(tags.contains("september"))
    }

    @Test func christmasSeasonIsActiveInDecember() {
        let tags = SeasonalTags.activeTags(on: date(month: 12, day: 20), calendar: calendar)
        #expect(tags.contains("christmas"))
        #expect(tags.contains("winter"))
        #expect(tags.contains("december"))
    }

    @Test func newYearSpanWrapsAcrossYearBoundary() {
        let december = SeasonalTags.activeTags(on: date(month: 12, day: 28), calendar: calendar)
        let january = SeasonalTags.activeTags(on: date(month: 1, day: 3), calendar: calendar)
        #expect(december.contains("new-year"))
        #expect(january.contains("new-year"))

        let midJanuary = SeasonalTags.activeTags(on: date(month: 1, day: 15), calendar: calendar)
        #expect(!midJanuary.contains("new-year"))
    }

    @Test func halloweenOnlyActiveInLateOctober() {
        #expect(SeasonalTags.activeTags(on: date(month: 10, day: 31), calendar: calendar).contains("halloween"))
        #expect(!SeasonalTags.activeTags(on: date(month: 10, day: 1), calendar: calendar).contains("halloween"))
    }

    @Test func southernHemisphereFlipsSeasons() {
        let january = SeasonalTags.activeTags(
            on: date(month: 1, day: 15), calendar: calendar, hemisphere: .southern
        )
        #expect(january.contains("summer"))
        #expect(!january.contains("winter"))
        #expect(january.contains("january"))

        let july = SeasonalTags.activeTags(
            on: date(month: 7, day: 15), calendar: calendar, hemisphere: .southern
        )
        #expect(july.contains("winter"))

        let september = SeasonalTags.activeTags(
            on: date(month: 9, day: 20), calendar: calendar, hemisphere: .southern
        )
        #expect(september.contains("spring"))
        #expect(!september.contains("autumn"))
    }

    @Test func holidaysAreUnaffectedByHemisphere() {
        let tags = SeasonalTags.activeTags(
            on: date(month: 12, day: 20), calendar: calendar, hemisphere: .southern
        )
        #expect(tags.contains("christmas"))
        #expect(tags.contains("december"))
        #expect(tags.contains("summer"))
        #expect(!tags.contains("winter"))
    }

    @Test func seasonalTagsOfQuoteAreCaseInsensitiveAndIgnoreOrganizationalTags() {
        let quote = Quote(text: "Ho ho ho", tags: ["Christmas", "work", "Funny"])
        #expect(SeasonalTags.seasonalTags(of: quote) == ["christmas"])
    }
}
