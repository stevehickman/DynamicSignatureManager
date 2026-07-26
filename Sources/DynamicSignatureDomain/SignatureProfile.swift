import Foundation

/// One signature the app maintains in Apple Mail: an identity plus the name
/// of the Mail signature it owns and which blocks to render. Users create one
/// profile per mail account (work, personal, …) and assign each profile's
/// signature to the matching account inside Mail.
public struct SignatureProfile: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    /// Label shown in the app's UI, e.g. "Work" or "Personal".
    public var name: String
    public var identity: Identity
    /// Name of the signature inside Apple Mail that this profile owns.
    /// Must be unique across profiles so they don't overwrite each other.
    public var signatureName: String
    public var template: SignatureTemplate
    /// Disabled profiles are kept but skipped during rotation and sync.
    public var isEnabled: Bool

    public init(
        id: UUID = UUID(),
        name: String = "",
        identity: Identity = Identity(),
        signatureName: String = "Dynamic Quote",
        template: SignatureTemplate = SignatureTemplate(),
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.identity = identity
        self.signatureName = signatureName
        self.template = template
        self.isEnabled = isEnabled
    }

    /// A profile is usable once the identity has a name and the Mail
    /// signature name isn't blank.
    public var isConfigured: Bool {
        identity.isConfigured
            && !signatureName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Name to display in lists, falling back to the identity or signature name.
    public var displayLabel: String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { return trimmed }
        let identityName = identity.displayName.trimmingCharacters(in: .whitespaces)
        if !identityName.isEmpty { return identityName }
        return signatureName
    }
}
