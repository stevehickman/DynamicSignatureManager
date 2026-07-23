//
//  ProfileJSONRepository.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public final class ProfileJSONRepository:
    ProfileRepository {


    private let repository:
        JSONRepository<Profile>


    public init(
        repository:
            JSONRepository<Profile>
    ) {

        self.repository =
            repository
    }



    public func profile(
        id:
        UUID
    ) throws -> Profile? {


        try repository
            .load()
            .first {
                $0.id == id
            }
    }



    public func save(
        _ profiles:
            [Profile]
    ) throws {

        try repository.save(
            profiles
        )
    }
}
