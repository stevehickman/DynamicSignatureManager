//
//  QuoteImporter.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public struct QuoteImporter {


    public init(){}



    public func importJSON(
        data:
            Data
    )
    throws -> [Quote] {


        try JSONCoding
            .decoder
            .decode(
                [Quote].self,
                from:
                    data
            )
    }
}
