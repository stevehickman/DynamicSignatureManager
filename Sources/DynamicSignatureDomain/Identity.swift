import Foundation

/// The person the signature belongs to.
public struct Identity: Codable, Hashable, Sendable {
    public var displayName: String
    public var title: String?
    public var organization: String?
    public var email: String?
    public var phone: String?
    public var website: String?

    public init(
        displayName: String = "",
        title: String? = nil,
        organization: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        website: String? = nil
    ) {
        self.displayName = displayName
        self.title = title
        self.organization = organization
        self.email = email
        self.phone = phone
        self.website = website
    }

    public var isConfigured: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
