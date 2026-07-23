//
//  MailSignature.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct MailSignature {


    public let name:
        String


    public let content:
        String



    public init(
        name:
            String,
        content:
            String
    ) {

        self.name =
            name

        self.content =
            content
    }
}
