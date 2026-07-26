import Foundation

public enum DomainError: Error, Equatable {
    case emptyText
    case invalidWeight
}

public enum DomainValidator {

    public static func validate(quote: Quote) throws {
        guard !quote.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DomainError.emptyText
        }
        guard quote.weight > 0 else {
            throw DomainError.invalidWeight
        }
    }
}
