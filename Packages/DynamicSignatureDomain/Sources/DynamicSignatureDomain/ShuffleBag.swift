//
//  ShuffleBag.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct ShuffleBag<Element: Hashable> {

    private var items: [Element]

    private var index: Int = 0


    public init(
        items: [Element]
    ) {

        self.items = items.shuffled()
    }


    public mutating func next() -> Element? {

        guard !items.isEmpty else {
            return nil
        }


        if index >= items.count {

            items.shuffle()

            index = 0
        }


        let item = items[index]

        index += 1

        return item
    }


    public mutating func reset() {

        items.shuffle()

        index = 0
    }
}
