//
//  SignatureRequestTests.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Testing
@testable import DynamicSignatureApplication


@Test
func requestCreatesDefaultTemplate()
{

    let request =
        SignatureRequest(
            profileID:
                UUID()
        )


    #expect(
        request.template.includeQuote
    )
}
