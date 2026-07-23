//
//  HistoryJSONRepository.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public final class HistoryJSONRepository:
    SignatureHistoryRepository {


    private let repository:
        JSONRepository<SignatureHistoryEntry>


    public init(
        repository:
            JSONRepository<SignatureHistoryEntry>
    ) {

        self.repository =
            repository
    }



    public func save(
        _ entry:
            SignatureHistoryEntry
    ) throws {


        var entries =
            try repository.load()


        entries.append(entry)


        try repository.save(
            entries
        )
    }
}
