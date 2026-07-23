//
//  AdaptiveQuoteSelector.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public struct AdaptiveQuoteSelector {


    public init(){}



    public func select(
        quotes:
            [Quote],
        history:
            [UUID]
    ) -> Quote? {


        let available =
            quotes
            .filter {

                $0.isEnabled &&
                !history.contains(
                    $0.id
                )
            }



        guard !available.isEmpty
        else {

            return nil
        }



        return available
            .sorted {

                if $0.weight != $1.weight {

                    return $0.weight > $1.weight
                }

                return $0.usageCount <
                    $1.usageCount
            }
            .first
    }
}
