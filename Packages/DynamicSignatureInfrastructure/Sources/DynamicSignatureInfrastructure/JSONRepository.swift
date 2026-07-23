//
//  JSONRepository.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public final class JSONRepository<Entity>
where Entity: Codable & Identifiable {


    private let fileURL: URL


    public init(
        fileURL: URL
    ) {

        self.fileURL = fileURL
    }


    public func load()
        throws -> [Entity] {


        guard FileManager.default
            .fileExists(
                atPath:
                fileURL.path()
            )
        else {

            return []
        }


        let data =
            try Data(
                contentsOf:
                    fileURL
            )


        return try JSONCoding
            .decoder
            .decode(
                [Entity].self,
                from: data
            )
    }


    public func save(
        _ entities: [Entity]
    ) throws {


        let data =
            try JSONCoding
                .encoder
                .encode(
                    entities
                )


        try data.write(
            to:
                fileURL,
            options:
                .atomic
        )
    }


    public func delete(
        id: Entity.ID
    ) throws {


        var items =
            try load()


        items.removeAll {
            $0.id == id
        }


        try save(items)
    }
}
