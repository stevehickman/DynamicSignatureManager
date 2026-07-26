import Foundation
import DynamicSignatureDomain

/// One-time upgrade from the single-identity era: if no profiles exist yet,
/// build a default profile from the legacy identity file plus the signature
/// name and template toggles that used to live in preferences.
public enum ProfileMigration {

    public static let defaultProfileName = "Default"

    /// Returns true when a default profile was created.
    @MainActor
    @discardableResult
    public static func migrateIfNeeded(
        profileRepository: ProfileRepository,
        legacyIdentityRepository: IdentityRepository,
        legacySignatureName: String,
        legacyTemplate: SignatureTemplate
    ) throws -> Bool {
        guard try profileRepository.loadAll().isEmpty else { return false }

        let legacyIdentity = (try? legacyIdentityRepository.load()) ?? nil
        let trimmedName = legacySignatureName.trimmingCharacters(in: .whitespaces)
        let profile = SignatureProfile(
            name: defaultProfileName,
            identity: legacyIdentity ?? Identity(),
            signatureName: trimmedName.isEmpty ? "Dynamic Quote" : trimmedName,
            template: legacyTemplate,
            isEnabled: true
        )
        try profileRepository.saveAll([profile])
        return true
    }
}
