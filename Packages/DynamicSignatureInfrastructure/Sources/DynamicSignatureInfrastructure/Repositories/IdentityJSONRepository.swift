//
//  IdentityJSONRepository.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public final class IdentityJSONRepository:
    IdentityRepository {


    private let repository:
        JSONRepository<Identity>


    public init(
        repository:
            JSONRepository<Identity>
    ) {

        self.repository =
            repository
    }



    public func identity(
        id:
        UUID
    ) throws -> Identity? {


        try repository
            .load()
            .first {
                $0.id == id
            }
    }



    public func save(
        _ identities:
            [Identity]
    ) throws {

        try repository.save(
            identities
        )
    }
}

