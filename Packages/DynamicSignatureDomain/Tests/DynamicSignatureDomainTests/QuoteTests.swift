//
//  QuoteTests.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Testing
@testable import DynamicSignatureDomain


@Test
func quoteCreation() {

    let quote = Quote(
        text: "The future is already here.",
        author: "William Gibson"
    )

    #expect(quote.text == "The future is already here.")
    #expect(quote.author == "William Gibson")
}

