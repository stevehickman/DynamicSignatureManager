//
//  SignatureViewModel.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


@MainActor
final class SignatureViewModel:
    ObservableObject {


    @Published
    var signatureText:
        String = ""


    func preview(
        signature:
            Signature
    ) {


        signatureText =
            signature.body ?? ""
    }
}
