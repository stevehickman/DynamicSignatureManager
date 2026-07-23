//
//  SignatureHistoryEntry.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct SignatureHistoryEntry:
    IdentifiableEntity {


    public let id: UUID


    public let signatureID: UUID


    public let quoteID: UUID?


    public let createdAt: Date


    public init(
        id: UUID = UUID(),
        signatureID: UUID,
        quoteID: UUID?,
        createdAt: Date = .now
    ) {

        self.id = id

        self.signatureID = signatureID

        self.quoteID = quoteID

        self.createdAt = createdAt
    }
}
