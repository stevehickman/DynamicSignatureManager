//
//  MenuBarView.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import SwiftUI


struct MenuBarView:
    View {


    @StateObject
    private var controller =
        MenuBarController()

    var body:
        some View {


        VStack {


            Button(
                "Generate New Signature"
            ) {

                controller.generate()
            }

            Button(
                "Copy Signature"
            ) {

                controller.copy()
            }


            Divider()


            Button(
                "Open Preferences"
            ) {

                NSApp.sendAction(
                    Selector(
                        "showSettingsWindow:"
                    ),
                    to:nil
                )
            }


            Divider()


            Button(
                "Quit"
            ) {

                NSApp.terminate(nil)
            }
        }
    }
}
