//
//  PreferencesView.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import SwiftUI


struct PreferencesView:
    View {


    @AppStorage(
        "includeQuotes"
    )
    private var includeQuotes =
        true



    var body:
        some View {


        Form {


            Toggle(
                "Include quotes",
                isOn:
                    $includeQuotes
            )

        }
        .padding()
        .frame(
            width:
                400
        )
    }
}
