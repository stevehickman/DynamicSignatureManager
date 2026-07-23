//
//  Rule.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation

public struct Rule: IdentifiableEntity {

    public let id: UUID

    public var name: String

    public var enabled: Bool

    public var priority: Int


    public init(
        id: UUID = UUID(),
        name: String,
        enabled: Bool = true,
        priority: Int = 0
    ) {

        self.id = id
        self.name = name
        self.enabled = enabled
        self.priority = priority
    }
}
