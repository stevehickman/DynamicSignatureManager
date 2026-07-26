import Foundation
import DynamicSignatureDomain

/// Everything the rotation pipeline needs to know, assembled by the app
/// from user preferences on each run.
public struct RotationConfiguration: Equatable, Sendable {
    public var isEnabled: Bool
    public var interval: RotationInterval
    /// Name of the signature inside Apple Mail that this app owns.
    public var signatureName: String
    /// How many recently used quotes to avoid repeating.
    public var recentQuoteLimit: Int
    public var template: SignatureTemplate

    public init(
        isEnabled: Bool = true,
        interval: RotationInterval = .daily,
        signatureName: String = "Dynamic Quote",
        recentQuoteLimit: Int = 10,
        template: SignatureTemplate = SignatureTemplate()
    ) {
        self.isEnabled = isEnabled
        self.interval = interval
        self.signatureName = signatureName
        self.recentQuoteLimit = recentQuoteLimit
        self.template = template
    }
}
