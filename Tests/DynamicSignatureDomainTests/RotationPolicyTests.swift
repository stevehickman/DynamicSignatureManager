import Foundation
import Testing
@testable import DynamicSignatureDomain

@Suite struct RotationPolicyTests {

    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func rotatesWhenNeverRotated() {
        for interval in RotationInterval.allCases {
            #expect(RotationPolicy.shouldRotate(lastRotated: nil, interval: interval, now: now))
        }
    }

    @Test func hourlyRespectsBoundary() {
        let underAnHour = now.addingTimeInterval(-3599)
        let overAnHour = now.addingTimeInterval(-3601)

        #expect(!RotationPolicy.shouldRotate(lastRotated: underAnHour, interval: .hourly, now: now))
        #expect(RotationPolicy.shouldRotate(lastRotated: overAnHour, interval: .hourly, now: now))
    }

    @Test func dailyUsesCalendarDays() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let startOfDay = calendar.startOfDay(for: now)
        let sameDay = startOfDay.addingTimeInterval(60)
        let previousDay = startOfDay.addingTimeInterval(-60)

        #expect(!RotationPolicy.shouldRotate(lastRotated: sameDay, interval: .daily, now: now, calendar: calendar))
        #expect(RotationPolicy.shouldRotate(lastRotated: previousDay, interval: .daily, now: now, calendar: calendar))
    }

    @Test func weeklyRespectsBoundary() {
        let sixDaysAgo = now.addingTimeInterval(-6 * 24 * 3600)
        let eightDaysAgo = now.addingTimeInterval(-8 * 24 * 3600)

        #expect(!RotationPolicy.shouldRotate(lastRotated: sixDaysAgo, interval: .weekly, now: now))
        #expect(RotationPolicy.shouldRotate(lastRotated: eightDaysAgo, interval: .weekly, now: now))
    }
}
