//
//  MailSignatureFormatter.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

public struct MailSignatureFormatter {


    public init(){}



    public func format(
        text:
            String
    )
    -> MailSignature {


        MailSignature(
            name:
                "Dynamic Signature",

            content:
                text
        )
    }
}
