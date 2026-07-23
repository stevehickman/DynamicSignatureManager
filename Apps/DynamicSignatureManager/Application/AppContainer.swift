//
//  AppContainer.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureApplication
import DynamicSignatureDomain


@MainActor
final class AppContainer:
    ObservableObject {


    let signatureService:
        SignatureService?



    init() {


        signatureService = nil

        /*
         Infrastructure wiring
         will be added after
         persistence integration.
        */
    }
}
