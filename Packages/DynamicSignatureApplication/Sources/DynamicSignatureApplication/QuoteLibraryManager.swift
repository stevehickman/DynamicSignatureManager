//
//  QuoteLibraryManager.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public final class QuoteLibraryManager {


    private let repository:
        QuoteRepository



    public init(
        repository:
            QuoteRepository
    ) {

        self.repository =
            repository
    }



    public func all()
    throws -> [Quote] {


        try repository.allQuotes()
    }



    public func enabled()
    throws -> [Quote] {


        try all()
            .filter {
                $0.isEnabled
            }
    }



    public func search(
        text:
        String
    ) throws -> [Quote] {


        try all()
            .filter {

                $0.text
                .localizedCaseInsensitiveContains(
                    text
                )
            }
    }
}
