//
//  Signature.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation

public struct Signature: IdentifiableEntity {

    public let id: UUID

    public var identityID: UUID

    public var quoteID: UUID?

    public var bannerIDs: [UUID]

    public var body: String?

    public var createdAt: Date


    public init(
        id: UUID = UUID(),
        identityID: UUID,
        quoteID: UUID? = nil,
        bannerIDs: [UUID] = [],
        body: String? = nil,
        createdAt: Date = .now
    ) {

        self.id = id
        self.identityID = identityID
        self.quoteID = quoteID
        self.bannerIDs = bannerIDs
        self.body = body
        self.createdAt = createdAt
    }
}
