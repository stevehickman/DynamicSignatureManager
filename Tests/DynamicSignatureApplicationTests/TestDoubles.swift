import Foundation
import DynamicSignatureDomain
@testable import DynamicSignatureApplication

final class InMemoryQuoteRepository: QuoteRepository {
    var quotes: [Quote]

    init(quotes: [Quote] = []) {
        self.quotes = quotes
    }

    func loadAll() throws -> [Quote] { quotes }
    func saveAll(_ quotes: [Quote]) throws { self.quotes = quotes }
}

final class InMemoryIdentityRepository: IdentityRepository {
    var identity: Identity?

    init(identity: Identity? = nil) {
        self.identity = identity
    }

    func load() throws -> Identity? { identity }
    func save(_ identity: Identity) throws { self.identity = identity }
}

final class InMemoryRotationStateRepository: RotationStateRepository {
    var state = RotationState()

    func load() throws -> RotationState { state }
    func save(_ state: RotationState) throws { self.state = state }
}

@MainActor
final class FakeMailUpdater: MailSignatureUpdating {
    var isMailRunning = true
    var applied: [(name: String, content: String)] = []
    var errorToThrow: Error?

    func apply(content: String, toSignatureNamed name: String) throws {
        if let errorToThrow {
            throw errorToThrow
        }
        applied.append((name, content))
    }
}
