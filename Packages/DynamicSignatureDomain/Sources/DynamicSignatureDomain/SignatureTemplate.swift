//
//  SignatureTemplate.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct SignatureTemplate: Codable, Hashable {


    public var includeIdentity: Bool

    public var includeBanner: Bool

    public var includeQuote: Bool


    public init(
        includeIdentity: Bool = true,
        includeBanner: Bool = true,
        includeQuote: Bool = true
    ) {

        self.includeIdentity = includeIdentity

        self.includeBanner = includeBanner

        self.includeQuote = includeQuote
    }
}
