//
//  AppDelegate.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import AppKit


final class AppDelegate:
    NSObject,
    NSApplicationDelegate {


    func applicationDidFinishLaunching(
        _ notification:
        Notification
    ) {


        NSApplication.shared
            .activationPolicy =
                .accessory
    }
}
