//
//  QuoteHistoryTracker.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct QuoteHistoryTracker {


    private var history:
        [UUID]


    private let limit:
        Int


    public init(
        limit: Int = 25
    ) {

        self.limit = limit

        self.history = []
    }


    public mutating func record(
        quoteID: UUID
    ) {

        history.append(
            quoteID
        )


        if history.count > limit {

            history.removeFirst(
                history.count - limit
            )
        }
    }


    public func contains(
        _ quoteID: UUID
    ) -> Bool {

        history.contains(
            quoteID
        )
    }
}
