import Foundation

/// Which hemisphere's seasons apply. Month and holiday tags are pure
/// calendar dates and identical in both; only season tags flip.
public enum Hemisphere: String, Codable, CaseIterable, Sendable {
    case northern
    case southern

    public var displayName: String {
        switch self {
        case .northern: "Northern"
        case .southern: "Southern"
        }
    }
}

/// Maps calendar dates to the seasonal tags active on that date, so quotes
/// tagged e.g. "winter", "december", or "christmas" only appear at the
/// matching time of year. Tag matching is case-insensitive.
public enum SeasonalTags {

    private static let monthNames = [
        "january", "february", "march", "april", "may", "june",
        "july", "august", "september", "october", "november", "december"
    ]

    /// Seasons follow meteorological boundaries, listed for the northern
    /// hemisphere: Dec–Feb winter, Mar–May spring, Jun–Aug summer, Sep–Nov
    /// autumn. The southern hemisphere is offset by six months.
    private static let seasonsByMonth: [Set<String>] = [
        ["winter"], ["winter"], ["spring"], ["spring"], ["spring"], ["summer"],
        ["summer"], ["summer"], ["autumn", "fall"], ["autumn", "fall"],
        ["autumn", "fall"], ["winter"]
    ]

    /// An inclusive month/day span; wraps across New Year when start > end.
    private struct HolidaySpan {
        let tag: String
        let start: Int // month * 100 + day
        let end: Int

        func contains(_ key: Int) -> Bool {
            start <= end ? (key >= start && key <= end) : (key >= start || key <= end)
        }
    }

    private static let holidays: [HolidaySpan] = [
        HolidaySpan(tag: "new-year", start: 1226, end: 107),
        HolidaySpan(tag: "valentines", start: 201, end: 214),
        HolidaySpan(tag: "halloween", start: 1015, end: 1031),
        HolidaySpan(tag: "thanksgiving", start: 1115, end: 1130),
        HolidaySpan(tag: "christmas", start: 1201, end: 1226)
    ]

    /// Every tag with calendar meaning. A quote carrying any of these is only
    /// selectable while that tag is active; all other tags are purely
    /// organizational and never affect selection.
    public static let recognized: Set<String> = {
        var tags = Set(monthNames)
        tags.formUnion(seasonsByMonth.flatMap { $0 })
        tags.formUnion(holidays.map { $0.tag })
        return tags
    }()

    /// The seasonal tags active on the given date: the month name, the
    /// season (for the given hemisphere), and any holiday spans covering
    /// the date.
    public static func activeTags(
        on date: Date = .now,
        calendar: Calendar = .current,
        hemisphere: Hemisphere = .northern
    ) -> Set<String> {
        let components = calendar.dateComponents([.month, .day], from: date)
        guard let month = components.month, let day = components.day,
              (1...12).contains(month) else {
            return []
        }

        let seasonMonth = hemisphere == .northern ? month : (month + 5) % 12 + 1
        var tags: Set<String> = [monthNames[month - 1]]
        tags.formUnion(seasonsByMonth[seasonMonth - 1])

        let key = month * 100 + day
        for holiday in holidays where holiday.contains(key) {
            tags.insert(holiday.tag)
        }
        return tags
    }

    /// The subset of a quote's tags that have calendar meaning, lowercased.
    public static func seasonalTags(of quote: Quote) -> Set<String> {
        Set(quote.tags.map { $0.lowercased() }).intersection(recognized)
    }
}
