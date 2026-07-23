//
//  SignatureConfiguration.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation

public struct SignatureConfiguration: Codable, Hashable {

    public var avoidRecentQuotes: Int

    public var includeAuthor: Bool

    public var includeCategory: Bool


    public init(
        avoidRecentQuotes: Int = 25,
        includeAuthor: Bool = true,
        includeCategory: Bool = false
    ) {

        self.avoidRecentQuotes = avoidRecentQuotes
        self.includeAuthor = includeAuthor
        self.includeCategory = includeCategory
    }
}
