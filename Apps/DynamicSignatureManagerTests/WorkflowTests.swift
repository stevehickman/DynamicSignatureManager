//
//  WorkflowTests.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Testing
@testable import DynamicSignatureApplication


@Test
func signatureRequestCreatesWorkflow()
{

    let request =
        SignatureRequest(
            profileID:
                UUID()
        )


    #expect(
        request.profileID != nil
    )
}
