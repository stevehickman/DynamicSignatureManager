//
//  SignatureService.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public final class SignatureService {


    private let generator:
        GenerateSignatureUseCase



    public init(
        generator:
            GenerateSignatureUseCase
    ) {

        self.generator =
            generator
    }



    public func generate(
        profile:
        UUID
    ) throws -> Signature {


        try generator.execute(

            request:
                SignatureRequest(
                    profileID:
                        profile
                )
        )
    }
}
