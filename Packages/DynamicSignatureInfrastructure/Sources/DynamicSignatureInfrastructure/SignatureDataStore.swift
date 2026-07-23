//
//  SignatureDataStore.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public final class SignatureDataStore {


    public let directory:
        StorageDirectory


    public lazy var quotes:
        JSONRepository<Quote>
        =
        repository(
            "quotes.json"
        )


    public lazy var identities:
        JSONRepository<Identity>
        =
        repository(
            "identities.json"
        )


    public lazy var profiles:
        JSONRepository<Profile>
        =
        repository(
            "profiles.json"
        )


    public lazy var banners:
        JSONRepository<Banner>
        =
        repository(
            "banners.json"
        )


    public init(
        directory:
            StorageDirectory
    ) {

        self.directory =
            directory
    }


    private func repository<T>(
        _ filename: String
    ) -> JSONRepository<T>
    where T: Codable & Identifiable {


        JSONRepository(
            fileURL:
                directory.url
                .appending(
                    path:
                    filename
                )
        )
    }
}
