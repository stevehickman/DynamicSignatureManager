//
//  SignatureViewModelTests.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Testing
@testable import DynamicSignatureManager


@Test
func viewModelStartsEmpty()
{

    let model =
        SignatureViewModel()


    #expect(
        model.signatureText == ""
    )
}
