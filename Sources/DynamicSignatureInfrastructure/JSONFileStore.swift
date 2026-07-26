import Foundation

public enum JSONCoding {

    public static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

/// Reads and writes one Codable value per file, atomically.
public struct JSONFileStore: Sendable {

    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public var fileExists: Bool {
        // percentEncoded: false matters — the default path() encoding breaks
        // paths containing spaces ("Application Support").
        FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false))
    }

    /// Returns nil when the file doesn't exist yet.
    public func load<T: Decodable>(_ type: T.Type) throws -> T? {
        guard fileExists else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try JSONCoding.decoder.decode(T.self, from: data)
    }

    public func save<T: Encodable>(_ value: T) throws {
        let data = try JSONCoding.encoder.encode(value)
        try data.write(to: fileURL, options: .atomic)
    }
}
