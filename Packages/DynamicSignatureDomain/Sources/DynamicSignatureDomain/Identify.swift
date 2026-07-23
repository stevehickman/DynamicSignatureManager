//
//  Identify.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation

public struct Identity: IdentifiableEntity {

    public let id: UUID

    public var displayName: String

    public var title: String?

    public var organization: String?

    public var email: String?

    public var phone: String?

    public var website: String?


    public init(
        id: UUID = UUID(),
        displayName: String,
        title: String? = nil,
        organization: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        website: String? = nil
    ) {

        self.id = id
        self.displayName = displayName
        self.title = title
        self.organization = organization
        self.email = email
        self.phone = phone
        self.website = website
    }
}
