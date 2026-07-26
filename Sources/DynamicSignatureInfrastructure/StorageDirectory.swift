import Foundation

/// The app's data folder: `~/Library/Application Support/DynamicSignatureManager`.
public struct StorageDirectory: Sendable {

    public let url: URL

    public init(baseURL: URL) {
        self.url = baseURL.appending(path: "DynamicSignatureManager")
    }

    public static func applicationSupport() -> StorageDirectory {
        StorageDirectory(
            baseURL: URL.applicationSupportDirectory
        )
    }

    public func createIfNeeded() throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    public func file(_ name: String) -> URL {
        url.appending(path: name)
    }
}
