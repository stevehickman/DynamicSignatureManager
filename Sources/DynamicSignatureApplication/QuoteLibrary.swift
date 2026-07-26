import Foundation
import DynamicSignatureDomain

/// CRUD and import/export for the editable quote database.
@MainActor
public final class QuoteLibrary {

    /// Minimal import format so hand-written JSON files work:
    /// `[{"text": "...", "author": "...", "tags": ["..."]}]`
    private struct SimpleQuote: Decodable {
        let text: String
        let author: String?
        let tags: Set<String>?
    }

    private let repository: QuoteRepository

    public init(repository: QuoteRepository) {
        self.repository = repository
    }

    public func allQuotes() throws -> [Quote] {
        try repository.loadAll()
    }

    public func add(_ quote: Quote) throws {
        try DomainValidator.validate(quote: quote)
        var quotes = try repository.loadAll()
        quotes.append(quote)
        try repository.saveAll(quotes)
    }

    public func update(_ quote: Quote) throws {
        try DomainValidator.validate(quote: quote)
        var quotes = try repository.loadAll()
        guard let index = quotes.firstIndex(where: { $0.id == quote.id }) else { return }
        quotes[index] = quote
        try repository.saveAll(quotes)
    }

    public func delete(ids: Set<UUID>) throws {
        var quotes = try repository.loadAll()
        quotes.removeAll { ids.contains($0.id) }
        try repository.saveAll(quotes)
    }

    public func setEnabled(_ isEnabled: Bool, id: UUID) throws {
        var quotes = try repository.loadAll()
        guard let index = quotes.firstIndex(where: { $0.id == id }) else { return }
        quotes[index].isEnabled = isEnabled
        try repository.saveAll(quotes)
    }

    /// Imports quotes from JSON data. Accepts either full `Quote` records
    /// (as produced by export) or a simple `[{"text":..., "author":...}]`
    /// array. Duplicate texts (case-insensitive) are skipped.
    /// Returns the number of quotes added.
    @discardableResult
    public func importQuotes(from data: Data) throws -> Int {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let imported: [Quote]
        if let full = try? decoder.decode([Quote].self, from: data) {
            imported = full
        } else {
            let simple = try decoder.decode([SimpleQuote].self, from: data)
            imported = simple.map { Quote(text: $0.text, author: $0.author, tags: $0.tags ?? []) }
        }

        var quotes = try repository.loadAll()
        var existingTexts = Set(quotes.map { normalized($0.text) })
        var added = 0

        for quote in imported {
            let key = normalized(quote.text)
            guard !key.isEmpty, !existingTexts.contains(key) else { continue }
            quotes.append(quote)
            existingTexts.insert(key)
            added += 1
        }

        if added > 0 {
            try repository.saveAll(quotes)
        }
        return added
    }

    public func exportData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(try repository.loadAll())
    }

    private func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
