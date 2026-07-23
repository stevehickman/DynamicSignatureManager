//
//  JSONCoding.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public enum JSONCoding {


    public static let encoder: JSONEncoder = {

        let encoder =
            JSONEncoder()

        encoder.outputFormatting =
            [
                .prettyPrinted,
                .sortedKeys
            ]

        encoder.dateEncodingStrategy =
            .iso8601

        return encoder
    }()


    public static let decoder: JSONDecoder = {

        let decoder =
            JSONDecoder()

        decoder.dateDecodingStrategy =
            .iso8601

        return decoder
    }()
}
