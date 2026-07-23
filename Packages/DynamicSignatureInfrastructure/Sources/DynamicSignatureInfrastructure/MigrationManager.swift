//
//  MigrationManager.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public final class MigrationManager {


    private var migrations:
        [Migration]


    public init(
        migrations:
            [Migration] = []
    ) {

        self.migrations =
            migrations
    }


    public func migrate(
        from:
            SchemaVersion,
        to:
            SchemaVersion,
        directory:
            URL
    ) throws {


        for migration in migrations {


            if migration.from == from {

                try migration
                    .migrate(
                        directory:
                            directory
                    )
            }
        }
    }
}
