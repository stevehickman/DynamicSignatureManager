//
//  WeightedRandomSelector.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct WeightedRandomSelector {


    public init() {}


    public func select(
        from quotes: [Quote]
    ) -> Quote? {


        let available =
            quotes.filter {
                $0.isEnabled &&
                $0.weight > 0
            }


        guard !available.isEmpty
        else {
            return nil
        }


        let totalWeight =
            available.reduce(0) {
                $0 + $1.weight
            }


        let random =
            Double.random(
                in: 0..<totalWeight
            )


        var current = 0.0


        for quote in available {

            current += quote.weight

            if random <= current {

                return quote
            }
        }


        return available.last
    }
}
