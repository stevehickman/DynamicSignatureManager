import Foundation

public enum ApplicationError: LocalizedError, Equatable {
    case noProfilesConfigured
    case noQuotesAvailable
    case mailNotRunning
    case mailSyncFailed(String)

    public var errorDescription: String? {
        switch self {
        case .noProfilesConfigured:
            "No usable signature profile. In Settings → Profiles, enable a profile and set its name."
        case .noQuotesAvailable:
            "No enabled quotes are available. Add or enable quotes in the Quote Library."
        case .mailNotRunning:
            "Apple Mail isn't running. The signature will sync the next time Mail opens."
        case .mailSyncFailed(let reason):
            "Couldn't update the Mail signature: \(reason)"
        }
    }
}
