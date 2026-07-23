//
//  SignatureRequest.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public struct SignatureRequest {


    public let profileID: UUID


    public let template:
        SignatureTemplate


    public init(
        profileID: UUID,
        template:
            SignatureTemplate =
            SignatureTemplate()
    ) {

        self.profileID =
            profileID

        self.template =
            template
    }
}
