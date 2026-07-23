//
//  Migration.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public protocol Migration {


    var from:
        SchemaVersion
    {
        get
    }


    var to:
        SchemaVersion
    {
        get
    }


    func migrate(
        directory: URL
    ) throws
}
