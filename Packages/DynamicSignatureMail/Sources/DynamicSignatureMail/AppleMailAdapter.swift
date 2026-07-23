//
//  AppleMailAdapter.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public final class AppleMailAdapter:
    MailSignatureProvider {


    public init(){}



    public func signatures()
    throws -> [MailSignature] {


        return []
    }



    public func update(
        _ signature:
            MailSignature
    )
    throws {


        /*
         Future implementation:

         ~/Library/Mail/V10/MailData/Signatures/

         Requires user permissions.
        */
    }
}
