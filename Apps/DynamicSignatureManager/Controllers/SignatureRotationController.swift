//
//  SignatureRotationController.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


@MainActor
public final class SignatureRotationController:
    ObservableObject {


    @Published
    public var currentSignature:
        Signature?



    private let generator:
        GenerateSignatureUseCase



    public init(
        generator:
            GenerateSignatureUseCase
    ) {

        self.generator =
            generator
    }



    public func rotate(
        profile:
            UUID
    )
    {


        do {

            currentSignature =
                try generator.execute(
                    request:
                        SignatureRequest(
                            profileID:
                                profile
                        )
                )

        }

        catch {

            print(
                error
            )
        }
    }
}
