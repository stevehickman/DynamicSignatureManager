//
//  BackupManager.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public final class BackupManager {


    public init() {}


    public func backup(
        source:
            URL,
        destination:
            URL
    ) throws {


        let timestamp =
            ISO8601DateFormatter()
                .string(
                    from:
                    .now
                )


        let backupURL =
            destination
            .appending(
                path:
                "backup-\(timestamp)"
            )


        try FileManager.default
            .copyItem(
                at:
                    source,
                to:
                    backupURL
            )
    }
}
