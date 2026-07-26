import Foundation
import DynamicSignatureDomain

/// Everything the rotation pipeline needs to know, assembled by the app
/// from user preferences on each run.
public struct RotationConfiguration: Equatable, Sendable {
    public var isEnabled: Bool
    public var interval: RotationInterval
    /// How many recently used quotes to avoid repeating.
    public var recentQuoteLimit: Int
    /// Restrict seasonally tagged quotes ("winter", "december", "christmas",
    /// …) to their time of year and prefer them while active.
    public var preferSeasonalQuotes: Bool
    /// Which hemisphere's seasons apply for season tags.
    public var hemisphere: Hemisphere

    public init(
        isEnabled: Bool = true,
        interval: RotationInterval = .daily,
        recentQuoteLimit: Int = 10,
        preferSeasonalQuotes: Bool = true,
        hemisphere: Hemisphere = .northern
    ) {
        self.isEnabled = isEnabled
        self.interval = interval
        self.recentQuoteLimit = recentQuoteLimit
        self.preferSeasonalQuotes = preferSeasonalQuotes
        self.hemisphere = hemisphere
    }
}
