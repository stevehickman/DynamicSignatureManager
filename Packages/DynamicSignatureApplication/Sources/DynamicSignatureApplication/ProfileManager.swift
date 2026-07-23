//
//  ProfileManager.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public final class ProfileManager {


    private let repository:
        ProfileRepository



    public init(
        repository:
            ProfileRepository
    ) {

        self.repository =
            repository
    }



    public func load(
        id:
        UUID
    ) throws -> Profile? {


        try repository
            .profile(
                id:
                id
            )
    }
}
