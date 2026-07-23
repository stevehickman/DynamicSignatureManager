//
//  Repository.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public protocol Repository<Entity> {

    associatedtype Entity: Codable & Identifiable


    func load() throws -> [Entity]


    func save(
        _ entities: [Entity]
    ) throws


    func delete(
        id: Entity.ID
    ) throws
}
