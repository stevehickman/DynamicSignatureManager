//
//  QuoteSelectionPolicy.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public enum QuoteSelectionPolicy: Codable, Hashable {

    case sequential

    case weighted

    case random

    case categoryFiltered(Set<UUID>)
}
