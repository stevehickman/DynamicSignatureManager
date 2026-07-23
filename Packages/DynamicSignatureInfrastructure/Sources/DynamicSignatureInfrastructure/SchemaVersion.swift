//
//  SchemaVersion.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct SchemaVersion:
    Codable,
    Hashable {


    public let major: Int

    public let minor: Int


    public init(
        major: Int,
        minor: Int
    ) {

        self.major = major

        self.minor = minor
    }
}
