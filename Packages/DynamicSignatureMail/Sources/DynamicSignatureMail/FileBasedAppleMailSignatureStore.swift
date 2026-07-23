//
//  FileBasedAppleMailSignatureStore.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public final class FileBasedAppleMailSignatureStore:
    MailSignatureStore {


    private let directory:
        URL



    public init(
        directory:
            URL
    ) {

        self.directory =
            directory
    }



    public func loadSignatures()
    throws -> [MailSignature] {


        guard FileManager.default
            .fileExists(
                atPath:
                    directory.path()
            )
        else {

            return []
        }


        return []
    }



    public func saveSignature(
        _ signature:
        MailSignature
    )
    throws {


        /*
         Implementation notes:

         Apple Mail signature files:

         ~/Library/Mail/
             MailData/
                 Signatures/

         Requires:
         - user permission
         - backup
         - atomic writes
        */
    }
}
