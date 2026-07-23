//
//  ComposerTests.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Testing
@testable import DynamicSignatureDomain


@Test
func signatureCompositionWorks() {


    let identity =
        Identity(
            displayName: "Steve Hickman",
            title: "Founder"
        )


    let quote =
        Quote(
            text: "Innovation distinguishes leaders.",
            author: "Steve Jobs"
        )


    let composer =
        SignatureComposer()


    let signature =
        composer.compose(
            identity: identity,
            quote: quote,
            banners: [],
            template: SignatureTemplate()
        )


    #expect(
        signature.body?
            .contains("Steve Hickman") == true
    )
}
