import Foundation
import DynamicSignatureDomain

/// Everything the rotation pipeline needs to know, assembled by the app
/// from user preferences on each run.
public struct RotationConfiguration: Equatable, Sendable {
    public var isEnabled: Bool
    public var interval: RotationInterval
    /// How many recently used quotes to avoid repeating.
    public var recentQuoteLimit: Int

    public init(
        isEnabled: Bool = true,
        interval: RotationInterval = .daily,
        recentQuoteLimit: Int = 10
    ) {
        self.isEnabled = isEnabled
        self.interval = interval
        self.recentQuoteLimit = recentQuoteLimit
    }
}
