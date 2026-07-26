import Foundation
import Testing
import DynamicSignatureDomain
@testable import DynamicSignatureApplication

@MainActor
@Suite struct ProfileMigrationTests {

    @Test func migratesLegacyIdentityIntoDefaultProfile() throws {
        let profileRepository = InMemoryProfileRepository()
        let identityRepository = InMemoryIdentityRepository(
            identity: Identity(displayName: "Steve Hickman", email: "steve@example.com")
        )
        let template = SignatureTemplate(includeIdentity: true, includeContactDetails: false, includeQuote: true)

        let migrated = try ProfileMigration.migrateIfNeeded(
            profileRepository: profileRepository,
            legacyIdentityRepository: identityRepository,
            legacySignatureName: "My Signature",
            legacyTemplate: template
        )

        #expect(migrated)
        #expect(profileRepository.profiles.count == 1)
        let profile = try #require(profileRepository.profiles.first)
        #expect(profile.name == ProfileMigration.defaultProfileName)
        #expect(profile.identity.displayName == "Steve Hickman")
        #expect(profile.signatureName == "My Signature")
        #expect(profile.template == template)
        #expect(profile.isEnabled)
        #expect(profile.isConfigured)
    }

    @Test func createsEmptyDefaultProfileOnFirstRun() throws {
        let profileRepository = InMemoryProfileRepository()
        let identityRepository = InMemoryIdentityRepository(identity: nil)

        let migrated = try ProfileMigration.migrateIfNeeded(
            profileRepository: profileRepository,
            legacyIdentityRepository: identityRepository,
            legacySignatureName: "  ",
            legacyTemplate: SignatureTemplate()
        )

        #expect(migrated)
        let profile = try #require(profileRepository.profiles.first)
        #expect(profile.signatureName == "Dynamic Quote")
        #expect(!profile.isConfigured)
    }

    @Test func doesNothingWhenProfilesAlreadyExist() throws {
        let existing = SignatureProfile(
            name: "Work",
            identity: Identity(displayName: "Steve"),
            signatureName: "Work Signature"
        )
        let profileRepository = InMemoryProfileRepository(profiles: [existing])
        let identityRepository = InMemoryIdentityRepository(
            identity: Identity(displayName: "Someone Else")
        )

        let migrated = try ProfileMigration.migrateIfNeeded(
            profileRepository: profileRepository,
            legacyIdentityRepository: identityRepository,
            legacySignatureName: "Dynamic Quote",
            legacyTemplate: SignatureTemplate()
        )

        #expect(!migrated)
        #expect(profileRepository.profiles == [existing])
    }
}
