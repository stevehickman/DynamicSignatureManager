import Foundation
import Testing
import DynamicSignatureDomain
@testable import DynamicSignatureInfrastructure

@Suite struct JSONFileStoreTests {

    private func temporaryFile() -> URL {
        FileManager.default.temporaryDirectory
            .appending(path: "dsm-test-\(UUID().uuidString).json")
    }

    @Test func loadReturnsNilForMissingFile() throws {
        let store = JSONFileStore(fileURL: temporaryFile())
        #expect(try store.load([Quote].self) == nil)
    }

    @Test func quoteRepositoryRoundTrip() throws {
        let url = temporaryFile()
        defer { try? FileManager.default.removeItem(at: url) }

        let repository = FileQuoteRepository(fileURL: url)
        #expect(!repository.hasStoredData)

        let quote = Quote(text: "Persist me", author: "Tester", weight: 1.5)
        try repository.saveAll([quote])

        #expect(repository.hasStoredData)

        let reloaded = FileQuoteRepository(fileURL: url)
        let loaded = try reloaded.loadAll()

        #expect(loaded.count == 1)
        #expect(loaded.first?.id == quote.id)
        #expect(loaded.first?.text == "Persist me")
        #expect(loaded.first?.weight == 1.5)
    }

    @Test func rotationStateRepositoryDefaultsToEmptyState() throws {
        let url = temporaryFile()
        defer { try? FileManager.default.removeItem(at: url) }

        let repository = FileRotationStateRepository(fileURL: url)
        let state = try repository.load()

        #expect(state.lastRotated == nil)
        #expect(state.recentQuoteIDs.isEmpty)
    }

    @Test func identityRepositoryRoundTrip() throws {
        let url = temporaryFile()
        defer { try? FileManager.default.removeItem(at: url) }

        let repository = FileIdentityRepository(fileURL: url)
        try repository.save(Identity(displayName: "Steve", email: "s@example.com"))

        let loaded = try repository.load()
        #expect(loaded?.displayName == "Steve")
        #expect(loaded?.email == "s@example.com")
    }

    @Test func worksInDirectoryContainingSpaces() throws {
        // Regression test: real data lives in "~/Library/Application Support",
        // and percent-encoded path handling once made every load return nil.
        let directory = FileManager.default.temporaryDirectory
            .appending(path: "dsm space test \(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let repository = FileQuoteRepository(fileURL: directory.appending(path: "quotes.json"))
        try repository.saveAll([Quote(text: "Spaced out")])

        #expect(repository.hasStoredData)
        #expect(try repository.loadAll().first?.text == "Spaced out")
    }

    @Test func defaultQuotesAreValid() {
        #expect(!DefaultQuotes.all.isEmpty)
        for quote in DefaultQuotes.all {
            #expect(!quote.text.isEmpty)
            #expect(quote.weight > 0)
            #expect(quote.isEnabled)
        }
    }
}
