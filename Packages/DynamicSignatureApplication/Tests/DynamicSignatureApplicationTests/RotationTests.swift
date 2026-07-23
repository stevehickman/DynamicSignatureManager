//
//  RotationTests.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Testing
@testable import DynamicSignatureApplication


@Test
func dailyRotationWorks()
{

    let service =
        SignatureRotationService()


    let result =
        service.shouldRotate(
            lastGenerated:
                nil,
            configuration:
                SignatureRotationConfiguration()
        )


    #expect(result)
}
