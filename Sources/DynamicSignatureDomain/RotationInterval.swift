import Foundation

/// How often the Mail signature should be refreshed with a new quote.
///
/// Apple Mail offers no supported per-message hook, so intervals are
/// wall-clock based; the menu bar app checks them while it is running.
public enum RotationInterval: String, Codable, CaseIterable, Sendable {
    case hourly
    case daily
    case weekly

    public var displayName: String {
        switch self {
        case .hourly: "Every hour"
        case .daily: "Every day"
        case .weekly: "Every week"
        }
    }
}

public enum RotationPolicy {

    public static func shouldRotate(
        lastRotated: Date?,
        interval: RotationInterval,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        guard let lastRotated else { return true }

        switch interval {
        case .hourly:
            return now.timeIntervalSince(lastRotated) >= 3600
        case .daily:
            return !calendar.isDate(lastRotated, inSameDayAs: now)
        case .weekly:
            return now.timeIntervalSince(lastRotated) >= 7 * 24 * 3600
        }
    }
}
