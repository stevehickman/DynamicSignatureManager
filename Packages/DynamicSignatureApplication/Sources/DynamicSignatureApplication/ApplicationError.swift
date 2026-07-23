//
//  ApplicationError.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public enum ApplicationError: Error {

    case profileNotFound

    case identityNotFound

    case noQuotesAvailable

    case generationFailed
}
