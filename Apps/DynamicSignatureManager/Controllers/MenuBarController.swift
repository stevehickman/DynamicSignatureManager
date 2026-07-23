//
//  MenuBarController.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


@MainActor
final class MenuBarController:
    ObservableObject {


    @Published
    var signature:
        String = ""



    func generate() {


        /*
         Connect to
         SignatureService
         */
    }



    func copy() {


        NSPasteboard.general
            .clearContents()


        NSPasteboard.general
            .setString(
                signature,
                forType:
                    .string
            )
    }
}
