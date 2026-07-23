//
//  DynamicSignatureManagerApp.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import SwiftUI


@main
struct DynamicSignatureManagerApp: App {


    @NSApplicationDelegateAdaptor(
        AppDelegate.self
    )
    var appDelegate


    var body: some Scene {


        MenuBarExtra(
            "Dynamic Signature Manager",
            systemImage:
                "signature"
        ) {

            MenuBarView()
        }


        Window(
            "Dynamic Signature Manager",
            id:
                "main"
        ) {

            ContentView()
        }


        Settings {

            PreferencesView()
        }
    }
}
