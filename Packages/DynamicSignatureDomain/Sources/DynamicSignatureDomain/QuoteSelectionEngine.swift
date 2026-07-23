//
//  QuoteSelectionEngine.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct QuoteSelectionEngine {


    private var bag: ShuffleBag<UUID>


    public init(
        quotes: [Quote]
    ) {

        self.bag = ShuffleBag(
            items: quotes.map(\.id)
        )
    }


    public mutating func nextQuote(
        from quotes: [Quote]
    ) -> Quote? {


        guard let id = bag.next()
        else {
            return nil
        }


        return quotes.first {
            $0.id == id &&
            $0.isEnabled
        }
    }
}
