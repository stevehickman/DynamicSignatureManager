//
//  QuoteJSONRepository.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public final class QuoteJSONRepository:
    QuoteRepository {


    private let repository:
        JSONRepository<Quote>


    public init(
        repository:
            JSONRepository<Quote>
    ) {

        self.repository =
            repository
    }


    public func allQuotes()
        throws -> [Quote] {

        try repository.load()
    }


    public func save(
        _ quotes:[Quote]
    ) throws {

        try repository.save(quotes)
    }
}
