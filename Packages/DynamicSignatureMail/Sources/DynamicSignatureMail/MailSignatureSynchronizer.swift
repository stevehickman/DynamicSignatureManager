//
//  MailSignatureSynchronizer.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public final class MailSignatureSynchronizer {


    private let store:
        MailSignatureStore



    public init(
        store:
            MailSignatureStore
    ) {

        self.store =
            store
    }



    public func synchronize(
        signature:
            MailSignature
    )
    throws {


        try store
            .saveSignature(
                signature
            )
    }
}
