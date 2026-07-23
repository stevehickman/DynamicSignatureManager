//
//  ApplicationRepositories.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public protocol QuoteRepository {

    func allQuotes()
        throws -> [Quote]
}


public protocol IdentityRepository {

    func identity(
        id: UUID
    ) throws -> Identity?
}


public protocol ProfileRepository {

    func profile(
        id: UUID
    ) throws -> Profile?
}


public protocol SignatureHistoryRepository {

    func save(
        _ entry:
        SignatureHistoryEntry
    ) throws
}

