//
//  DataImporter.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct DataImporter {


    public init(){}


    public func importData<T>(
        _ data:
            Data,
        as:
            T.Type
    ) throws -> T
    where T: Codable {


        try JSONCoding
            .decoder
            .decode(
                T.self,
                from:
                    data
            )
    }
}
