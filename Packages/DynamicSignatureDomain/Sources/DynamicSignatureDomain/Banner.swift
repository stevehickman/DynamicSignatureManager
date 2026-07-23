//
//  Banner.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation

public struct Banner: IdentifiableEntity {

    public let id: UUID

    public var text: String

    public var priority: Int

    public var startDate: Date?

    public var endDate: Date?

    public var isEnabled: Bool


    public init(
        id: UUID = UUID(),
        text: String,
        priority: Int = 0,
        startDate: Date? = nil,
        endDate: Date? = nil,
        isEnabled: Bool = true
    ) {

        self.id = id
        self.text = text
        self.priority = priority
        self.startDate = startDate
        self.endDate = endDate
        self.isEnabled = isEnabled
    }
}
