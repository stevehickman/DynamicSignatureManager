import Foundation
import Testing
import DynamicSignatureDomain
@testable import DynamicSignatureApplication

@MainActor
@Suite struct QuoteLibraryTests {

    @Test func addRejectsEmptyText() {
        let library = QuoteLibrary(repository: InMemoryQuoteRepository())

        #expect(throws: DomainError.emptyText) {
            try library.add(Quote(text: "   "))
        }
    }

    @Test func crudRoundTrip() throws {
        let repository = InMemoryQuoteRepository()
        let library = QuoteLibrary(repository: repository)

        var quote = Quote(text: "Original")
        try library.add(quote)
        #expect(repository.quotes.count == 1)

        quote.text = "Edited"
        try library.update(quote)
        #expect(repository.quotes.first?.text == "Edited")

        try library.setEnabled(false, id: quote.id)
        #expect(repository.quotes.first?.isEnabled == false)

        try library.delete(ids: [quote.id])
        #expect(repository.quotes.isEmpty)
    }

    @Test func importsSimpleFormatAndSkipsDuplicates() throws {
        let repository = InMemoryQuoteRepository(quotes: [Quote(text: "Existing quote")])
        let library = QuoteLibrary(repository: repository)

        let json = """
        [
            {"text": "Existing Quote", "author": "Duplicate"},
            {"text": "Brand new quote", "author": "Someone"},
            {"text": ""}
        ]
        """.data(using: .utf8)!

        let added = try library.importQuotes(from: json)

        #expect(added == 1)
        #expect(repository.quotes.count == 2)
        #expect(repository.quotes.last?.author == "Someone")
    }

    @Test func exportRoundTripsThroughImport() throws {
        let source = InMemoryQuoteRepository(quotes: [
            Quote(text: "First", author: "A", weight: 2.0),
            Quote(text: "Second")
        ])
        let sourceLibrary = QuoteLibrary(repository: source)
        let data = try sourceLibrary.exportData()

        let destination = InMemoryQuoteRepository()
        let destinationLibrary = QuoteLibrary(repository: destination)
        let added = try destinationLibrary.importQuotes(from: data)

        #expect(added == 2)
        #expect(destination.quotes.first?.author == "A")
        #expect(destination.quotes.first?.weight == 2.0)
    }
}
