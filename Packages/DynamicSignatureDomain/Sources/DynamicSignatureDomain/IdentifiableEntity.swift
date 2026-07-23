//
//  IdentifiableEntity.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation

public protocol IdentifiableEntity: Identifiable, Codable, Hashable
where ID == UUID {

    var id: UUID { get }

}
