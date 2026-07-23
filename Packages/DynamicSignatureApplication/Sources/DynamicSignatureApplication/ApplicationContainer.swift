//
//  ApplicationContainer.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public final class ApplicationContainer {


    public init(){}


    public func makeSignatureService()
    -> SignatureService {


        fatalError(
            "Infrastructure wiring required"
        )
    }
}
