//
//  DataExporter.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct DataExporter {


    public init(){}


    public func export<T>(
        _ objects:
            [T]
    ) throws -> Data
    where T: Codable {


        try JSONCoding
            .encoder
            .encode(
                objects
            )
    }
}
