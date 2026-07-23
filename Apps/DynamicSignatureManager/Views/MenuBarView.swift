//
//  MenuBarView.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import SwiftUI


struct MenuBarView:
    View {


    var body:
        some View {


        VStack {


            Button(
                "Generate Signature"
            ) {


            }


            Divider()


            Button(
                "Preferences..."
            ) {


                NSApp.sendAction(
                    Selector(
                        "showSettingsWindow:"
                    ),
                    to:
                        nil,
                    from:
                        nil
                )
            }


            Divider()


            Button(
                "Quit"
            ) {

                NSApplication.shared
                    .terminate(nil)
            }
        }
        .padding()
    }
}
