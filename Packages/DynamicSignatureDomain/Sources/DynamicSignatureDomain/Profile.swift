//
//  Profile.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation

public struct Profile: IdentifiableEntity {

    public let id: UUID

    public var name: String

    public var identityID: UUID

    public var quoteCategoryIDs: Set<UUID>

    public var includeQuotes: Bool

    public var includeBanners: Bool

    public var isDefault: Bool


    public init(
        id: UUID = UUID(),
        name: String,
        identityID: UUID,
        quoteCategoryIDs: Set<UUID> = [],
        includeQuotes: Bool = true,
        includeBanners: Bool = true,
        isDefault: Bool = false
    ) {

        self.id = id
        self.name = name
        self.identityID = identityID
        self.quoteCategoryIDs = quoteCategoryIDs
        self.includeQuotes = includeQuotes
        self.includeBanners = includeBanners
        self.isDefault = isDefault
    }
}
