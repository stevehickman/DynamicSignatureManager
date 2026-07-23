//
//  MailSignatureProvider.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

public protocol MailSignatureProvider {


    func signatures()
    throws -> [MailSignature]



    func update(
        _ signature:
            MailSignature
    )
    throws
}
