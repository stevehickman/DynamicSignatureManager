//
//  StorageDirectory.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct StorageDirectory {


    public let url: URL


    public init(
        baseURL: URL
    ) {

        self.url =
            baseURL
            .appending(
                path:
                "DynamicSignatureManager"
            )
    }


    public func createIfNeeded()
        throws {

        try FileManager.default
            .createDirectory(
                at: url,
                withIntermediateDirectories:
                    true
            )
    }
}
