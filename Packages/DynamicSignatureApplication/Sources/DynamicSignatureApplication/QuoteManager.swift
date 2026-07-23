//
//  QuoteManager.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public final class QuoteManager {


    private let repository:
        QuoteRepository


    public init(
        repository:
            QuoteRepository
    ) {

        self.repository =
            repository
    }



    public func enabledQuotes()
        throws -> [Quote] {


        try repository
            .allQuotes()
            .filter(\.isEnabled)
    }
}
