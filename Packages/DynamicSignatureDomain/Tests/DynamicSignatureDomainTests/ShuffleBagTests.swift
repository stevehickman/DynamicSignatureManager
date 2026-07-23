//
//  ShuffleBagTests.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Testing
@testable import DynamicSignatureDomain


@Test
func shuffleBagReturnsAllItems() {


    var bag =
        ShuffleBag(
            items: [1,2,3,4,5]
        )


    var values:Set<Int> = []


    for _ in 0..<5 {

        if let value = bag.next() {

            values.insert(value)
        }
    }


    #expect(values.count == 5)
}
