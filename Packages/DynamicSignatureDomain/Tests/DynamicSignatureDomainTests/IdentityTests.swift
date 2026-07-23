//
//  IdentityTests.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Testing
@testable import DynamicSignatureDomain


@Test
func identityCreation() {

    let identity = Identity(
        displayName: "Steve Hickman",
        title: "Founder"
    )

    #expect(identity.displayName == "Steve Hickman")
    #expect(identity.title == "Founder")
}
