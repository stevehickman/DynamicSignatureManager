//
//  ClipboardService.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import AppKit


public final class ClipboardService {


    public init(){}



    public func copy(
        _ text:
        String
    ) {


        let pasteboard =
            NSPasteboard.general


        pasteboard.clearContents()


        pasteboard.setString(
            text,
            forType:
                .string
        )
    }
}

