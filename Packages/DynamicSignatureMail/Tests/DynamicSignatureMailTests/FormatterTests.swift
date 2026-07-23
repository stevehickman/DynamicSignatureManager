//
//  FormatterTests.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Testing
@testable import DynamicSignatureMail


@Test
func formatterCreatesMailSignature()
{

    let formatter =
        MailSignatureFormatter()


    let result =
        formatter.format(
            text:
            "Hello"
        )


    #expect(
        result.content == "Hello"
    )
}
