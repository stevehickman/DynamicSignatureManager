//
//  DomainValidation.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public enum DomainValidator {


    public static func validate(
        quote: Quote
    ) throws {


        guard !quote.text.isEmpty
        else {

            throw DomainError.emptyText
        }


        guard quote.weight > 0
        else {

            throw DomainError.invalidWeight
        }
    }


    public static func validate(
        identity: Identity
    ) throws {


        guard !identity.displayName.isEmpty
        else {

            throw DomainError.missingIdentity
        }
    }
}
