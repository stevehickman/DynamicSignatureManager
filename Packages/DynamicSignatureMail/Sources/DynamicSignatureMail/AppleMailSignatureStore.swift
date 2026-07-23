//
//  AppleMailSignatureStore.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public protocol MailSignatureStore {


    func loadSignatures()
    throws -> [MailSignature]


    func saveSignature(
        _ signature:
        MailSignature
    )
    throws
}
